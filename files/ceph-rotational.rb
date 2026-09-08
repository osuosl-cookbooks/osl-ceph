#!/opt/cinc/embedded/bin/ruby
# frozen_string_literal: true

# Correct the kernel rotational flag for SSDs behind MegaRAID virtual drives,
# which report rotational=1 regardless of the physical media.

require 'chef/mixin/shell_out'
require 'json'

module CephRotational
  extend Chef::Mixin::ShellOut

  STORCLI_PATHS = %w(
    /opt/MegaRAID/storcli/storcli64
    /opt/MegaRAID/storcli/storcli
    /usr/sbin/storcli64
    /usr/sbin/storcli
    /usr/local/sbin/storcli64
  ).freeze

  STORCLI_TIMEOUT = 30

  # From drivers/scsi/megaraid/megaraid_sas.h
  MEGASAS_MAX_PD_CHANNELS = 2
  MEGASAS_MAX_DEV_PER_CHANNEL = 128

  # The controller is the last PCI component before the SCSI host: bridges and
  # driver-specific nodes (ata, port-, end_device-) can precede it.
  HOST_PREFIX_RE = %r{\A(.*?)/host\d+/}.freeze
  PCI_COMPONENT_RE = /\h{4}:\h{2}:\h{2}\.\d/.freeze
  SCSI_ADDR_RE = %r{/host\d+/target\d+:\d+:\d+/\d+:(\d+):(\d+):\d+/}.freeze

  module_function

  def log(msg)
    puts "ceph-rotational: #{msg}"
  end

  def log_warning(msg)
    puts "ceph-rotational: WARNING: #{msg}"
  end

  def which(bin)
    ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).each do |dir|
      candidate = File.join(dir, bin)
      return candidate if File.executable?(candidate)
    end
    nil
  end

  def find_storcli
    STORCLI_PATHS.find { |p| File.executable?(p) } ||
      which('storcli64') ||
      which('storcli')
  end

  # storcli reports '01:03:00:00', sysfs uses '0001:03:00.0': every field is hex
  # and zero-padded, so parse and re-format all four.
  def normalize_pci(addr)
    parts = addr.to_s.split(':')
    return unless parts.length == 4

    domain, bus, dev, func = parts.map { |p| Integer(p, 16) }
    format('%04x:%02x:%02x.%x', domain, bus, dev, func)
  rescue ArgumentError, TypeError
    nil
  end

  def numeric?(value)
    value.is_a?(Integer) || (value.is_a?(String) && value.strip.match?(/\A\d+\z/))
  end

  # Channels 0..1 carry physical drives whose target id is a PD device id, and
  # those overlap VD numbers, so they must not be looked up as virtual drives.
  def virtual_drive_number(channel, target)
    return if channel < MEGASAS_MAX_PD_CHANNELS

    ((channel % 2) * MEGASAS_MAX_DEV_PER_CHANNEL) + target
  end

  # => { '0001:03:00.0' => { vd_number => 'SSD' | 'HDD' } }
  def controllers_from(data)
    data.fetch('Controllers', []).each_with_object({}) do |ctrl, acc|
      response = ctrl['Response Data'] || {}
      pci = controller_pci(response)
      next unless pci

      dg_media = {}
      response.fetch('PD LIST', []).each do |pd|
        next unless numeric?(pd['DG'])

        dg_media[pd['DG'].to_i] = pd['Med'].to_s.strip.upcase
      end

      vd_media = {}
      # The drive group is not always the VD number, so follow DG/VD rather than
      # assuming the two match.
      response.fetch('VD LIST', []).each do |vd|
        dg, vdnum = vd['DG/VD'].to_s.split('/', 2)
        unless numeric?(dg) && numeric?(vdnum)
          log_warning "unrecognised VD entry #{vd['DG/VD'].inspect}, skipping it"
          next
        end

        vd_media[vdnum.to_i] = dg_media[dg.to_i]
      end

      acc[pci] = vd_media
    end
  end

  # Basics has a formatted PCI Address on storcli v7; Bus has the same
  # coordinates as integers. Some controllers and storcli2 omit one or the other.
  def controller_pci(response)
    normalize_pci(response.dig('Basics', 'PCI Address')) || pci_from_bus(response)
  end

  def pci_from_bus(response)
    bus = response['Bus']
    return unless bus.is_a?(Hash)

    fields = bus.values_at('Domain ID', 'Bus Number', 'Device Number', 'Function Number')
    return unless fields.all? { |f| numeric?(f) }

    domain, busno, dev, func = fields.map(&:to_i)
    format('%04x:%02x:%02x.%x', domain, busno, dev, func)
  end

  # Whole disks expose queue/rotational directly; a partition (an LVM PV may be
  # one) does not, and has to be resolved to its parent disk.
  def rotational_path(name)
    direct = "/sys/block/#{name}/queue/rotational"
    return direct if File.exist?(direct)

    parent = File.join(File.dirname(File.realpath("/sys/class/block/#{name}")), 'queue', 'rotational')
    parent if File.exist?(parent)
  rescue SystemCallError
    nil
  end

  def read_rotational(name)
    path = rotational_path(name)
    return unless path

    File.read(path).strip
  rescue SystemCallError
    nil
  end

  def set_rotational(dev, value, why)
    path = rotational_path(dev)
    current = path && File.read(path).strip
    return 0 if current.nil? || current == value.to_s

    File.write(path, value.to_s)
    log "#{dev}: rotational #{current} -> #{value} (#{why})"
    1
  rescue SystemCallError => e
    log_warning "#{dev}: cannot set rotational: #{e.message}"
    0
  end

  def device_sysfs_path(block_path)
    "#{File.realpath("#{block_path}/device")}/"
  rescue SystemCallError
    nil
  end

  def controller_pci_of(path)
    prefix = path[HOST_PREFIX_RE, 1]
    prefix&.scan(PCI_COMPONENT_RE)&.last
  end

  # => [devices changed, devices matched to a virtual drive]
  def apply(controllers)
    changed = 0
    matched = 0

    Dir.glob('/sys/block/sd*').sort.each do |block_path|
      dev = File.basename(block_path)
      real = device_sysfs_path(block_path)
      next unless real

      pci = controller_pci_of(real)
      scsi = real.match(SCSI_ADDR_RE)
      next unless pci && scsi

      vd = virtual_drive_number(scsi[1].to_i, scsi[2].to_i)
      next unless vd

      media = controllers.dig(pci, vd)
      next unless media

      matched += 1
      case media
      when 'SSD' then changed += set_rotational(dev, 0, "VD #{vd} is SSD")
      when 'HDD' then changed += set_rotational(dev, 1, "VD #{vd} is HDD")
      end
    end

    [changed, matched]
  end

  # BlueStore opens the LV, not the raw disk. At boot the LV inherits the fixed
  # flag; this pass exists so a manual run also corrects already-active LVs.
  def propagate_to_device_mapper
    changed = 0
    Dir.glob('/sys/block/dm-*').sort.each do |dm_path|
      slaves = dm_slaves(dm_path)
      next if slaves.empty?
      next unless slaves.all? { |slave| read_rotational(slave) == '0' }

      changed += set_rotational(File.basename(dm_path), 0, 'all backing devices are SSD')
    end
    changed
  end

  def dm_slaves(dm_path)
    Dir.children("#{dm_path}/slaves")
  rescue SystemCallError
    []
  end

  def storcli_data(storcli)
    result = shell_out(storcli, '/call', 'show', 'all', 'J', timeout: STORCLI_TIMEOUT)
    if result.error? || result.stdout.strip.empty?
      log_warning "#{storcli} returned no usable data, rotational flags were not corrected"
      return
    end

    JSON.parse(result.stdout)
  rescue JSON::ParserError => e
    log_warning "could not parse storcli output: #{e.message}"
    nil
  rescue StandardError => e
    log_warning "could not run #{storcli}: #{e.message}"
    nil
  end

  # Never returns non-zero: this runs from a unit Chef starts, and a failed unit
  # would abort every future converge with no self-recovery.
  def run
    unless Dir.exist?('/sys/module/megaraid_sas')
      log 'megaraid_sas not loaded, nothing to do'
      return 0
    end

    storcli = find_storcli
    if storcli.nil?
      log_warning 'megaraid_sas is loaded but storcli is not installed, so the ' \
                  'physical media type cannot be determined and any SSD behind ' \
                  'this controller stays mis-detected as a spinner (storcli is ' \
                  'installed by osl-nrpe::check_raid)'
      return 0
    end

    data = storcli_data(storcli)
    return 0 if data.nil?

    controllers = controllers_from(data)
    if controllers.empty?
      log_warning 'storcli returned data but no controller could be identified ' \
                  'from it, so rotational flags were not corrected'
      return 0
    end

    changed, matched = apply(controllers)
    if matched.zero?
      log_warning "#{controllers.length} controller(s) reported by storcli but no " \
                  'block device could be matched to any of their virtual drives, ' \
                  'so rotational flags were not corrected'
    end

    changed += propagate_to_device_mapper
    log "#{changed} device(s) updated"
    0
  end
end

exit CephRotational.run if $PROGRAM_NAME == __FILE__
