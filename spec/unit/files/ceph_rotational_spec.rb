# spec_helper must load first: requiring the script first activates the chef gem
# on its own and leaves chefspec unable to load for the rest of the suite.
require_relative '../../spec_helper'
require_relative '../../../files/ceph-rotational'

describe CephRotational do
  def fixture(name)
    JSON.parse(File.read(File.expand_path("../../fixtures/#{name}.json", __dir__)))
  end

  # Real `storcli /call show all J` from op-ceph1: five SSDs and seven HDDs, each
  # its own RAID0 virtual drive. The drive group does not track the VD number.
  let(:storcli_data) { fixture('storcli-op-ceph1') }
  let(:controller_pci) { '0001:03:00.0' }
  let(:controllers) { described_class.controllers_from(storcli_data) }

  # Real path from op-ceph1 (readlink -f /sys/block/sda/device), bridges and all.
  # Channel 2 is the first logical-drive channel.
  def sysfs_path(target, channel: 2)
    '/sys/devices/pci0001:00/0001:00:00.0/0001:01:00.0/0001:02:01.0/0001:03:00.0/' \
      "host0/target0:#{channel}:#{target}/0:#{channel}:#{target}:0/"
  end

  before do
    # Keep test output clean; message content is asserted explicitly where it matters.
    allow(described_class).to receive(:log)
    allow(described_class).to receive(:log_warning)
  end

  describe '.normalize_pci' do
    it 'converts a storcli address to the sysfs form' do
      expect(described_class.normalize_pci('01:03:00:00')).to eq controller_pci
    end

    it 'pads the domain to four digits' do
      expect(described_class.normalize_pci('00:5d:00:01')).to eq '0000:5d:00.1'
    end

    it 'downcases hexadecimal so it matches sysfs' do
      expect(described_class.normalize_pci('00:AF:00:00')).to eq '0000:af:00.0'
    end

    it 'zero-pads short fields, which storcli2 emits' do
      expect(described_class.normalize_pci('0:3:0:0')).to eq '0000:03:00.0'
    end

    it 'treats the function as hexadecimal rather than decimal' do
      expect(described_class.normalize_pci('01:03:00:0a')).to eq '0001:03:00.a'
    end

    it 'returns nil when the address has the wrong number of fields' do
      expect(described_class.normalize_pci('01:03:00')).to be_nil
    end

    it 'returns nil when the address is not hexadecimal' do
      expect(described_class.normalize_pci('zz:03:00:00')).to be_nil
    end

    it 'returns nil when the address is missing' do
      expect(described_class.normalize_pci(nil)).to be_nil
    end
  end

  describe '.virtual_drive_number' do
    it 'maps the first logical-drive channel straight through' do
      expect(described_class.virtual_drive_number(2, 11)).to eq 11
    end

    it 'offsets the second logical-drive channel by 128' do
      expect(described_class.virtual_drive_number(3, 5)).to eq 133
    end

    it 'refuses physical-drive channels, whose target id is a PD device id' do
      # PD device ids on op-ceph1 are 11..22 and overlap the VD numbers 0..11,
      # so treating one as a VD number would flag an unrelated disk.
      expect(described_class.virtual_drive_number(0, 11)).to be_nil
      expect(described_class.virtual_drive_number(1, 22)).to be_nil
    end
  end

  describe '.controllers_from' do
    it 'keys the result by the normalized PCI address' do
      expect(controllers.keys).to eq [controller_pci]
    end

    it 'follows DG/VD rather than assuming the drive group is the VD number' do
      # VD 3 lives in DG 11 (Micron SSD) and VD 11 in DG 10 (Samsung SSD);
      # assuming DG == VD would mis-read both as HDDs.
      expect(controllers[controller_pci][3]).to eq 'SSD'
      expect(controllers[controller_pci][11]).to eq 'SSD'
    end

    it 'maps the Samsung SSDs whose drive group matches the VD number' do
      expect(controllers[controller_pci].values_at(0, 1, 2)).to eq %w(SSD SSD SSD)
    end

    it 'maps the seven Seagate HDDs' do
      expect(controllers[controller_pci].values_at(4, 5, 6, 7, 8, 9, 10)).to all(eq('HDD'))
    end

    it 'identifies every virtual drive on the controller' do
      expect(controllers[controller_pci].length).to eq 12
    end

    it 'falls back to the Bus section when Basics has no PCI Address' do
      storcli_data['Controllers'][0]['Response Data'].delete('Basics')
      expect(controllers.keys).to eq [controller_pci]
    end

    context 'with a different controller model (real capture from fs1)' do
      let(:storcli_data) { fixture('storcli-fs1') }

      it 'reads a Dell PERC as readily as an AVAGO card' do
        expect(storcli_data.dig('Controllers', 0, 'Response Data', 'Basics', 'Model'))
          .to eq 'PERC H730P Mini'
        expect(controllers.keys).to eq ['0000:02:00.0']
      end

      it 'reports an all-spinner controller as all HDD' do
        expect(controllers['0000:02:00.0'].values).to all(eq('HDD'))
        expect(controllers['0000:02:00.0'].length).to eq 8
      end
    end

    it 'returns an empty hash when there are no controllers' do
      expect(described_class.controllers_from({})).to eq({})
    end

    it 'skips controllers with no usable PCI address' do
      expect(described_class.controllers_from('Controllers' => [{}])).to eq({})
    end

    it 'skips unconfigured drives whose drive group is "-"' do
      data = {
        'Controllers' => [
          {
            'Response Data' => {
              'Basics' => { 'PCI Address' => '01:03:00:00' },
              'VD LIST' => [{ 'DG/VD' => '0/0' }],
              'PD LIST' => [{ 'DG' => '-', 'Med' => 'SSD' }, { 'DG' => 0, 'Med' => 'HDD' }],
            },
          },
        ],
      }
      expect(described_class.controllers_from(data)).to eq(controller_pci => { 0 => 'HDD' })
    end

    it 'warns and skips a VD entry that is not in DG/VD form' do
      data = {
        'Controllers' => [
          {
            'Response Data' => {
              'Basics' => { 'PCI Address' => '01:03:00:00' },
              'VD LIST' => [{ 'DG/VD' => 0 }],
              'PD LIST' => [{ 'DG' => 0, 'Med' => 'SSD' }],
            },
          },
        ],
      }
      expect(described_class).to receive(:log_warning).with(/unrecognised VD entry/)
      expect(described_class.controllers_from(data)).to eq(controller_pci => {})
    end
  end

  describe '.controller_pci_of' do
    it 'finds the controller a megaraid virtual drive hangs off' do
      expect(described_class.controller_pci_of(sysfs_path(11))).to eq controller_pci
    end

    it 'tolerates components between the controller and the SCSI host' do
      # Real AHCI path shape: an ata node sits between the PCI device and host.
      path = '/sys/devices/pci0000:80/0000:80:17.0/ata6/host5/target5:0:0/5:0:0:0/'
      expect(described_class.controller_pci_of(path)).to eq '0000:80:17.0'
    end

    it 'picks the endpoint rather than a parent bridge' do
      path = '/sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/host2/target2:0:0/2:0:0:0/'
      expect(described_class.controller_pci_of(path)).to eq '0000:01:00.0'
    end

    it 'returns nil for a path with no SCSI host' do
      expect(described_class.controller_pci_of('/sys/devices/virtual/block/dm-0/')).to be_nil
    end
  end

  describe '.read_rotational' do
    it 'returns the stripped flag for a whole disk' do
      allow(File).to receive(:exist?).with('/sys/block/sda/queue/rotational').and_return(true)
      allow(File).to receive(:read).with('/sys/block/sda/queue/rotational').and_return("1\n")
      expect(described_class.read_rotational('sda')).to eq '1'
    end

    it 'resolves a partition to its parent disk' do
      # An LVM PV is often a partition, and partitions have no /sys/block entry
      # and no queue/ directory of their own.
      allow(File).to receive(:exist?).with('/sys/block/sda1/queue/rotational').and_return(false)
      allow(File).to receive(:realpath).with('/sys/class/block/sda1')
                                       .and_return('/sys/devices/pci0000:00/0000:00:17.0/ata1/host0/target0:0:0/0:0:0:0/block/sda/sda1')
      parent = '/sys/devices/pci0000:00/0000:00:17.0/ata1/host0/target0:0:0/0:0:0:0/block/sda/queue/rotational'
      allow(File).to receive(:exist?).with(parent).and_return(true)
      allow(File).to receive(:read).with(parent).and_return("0\n")
      expect(described_class.read_rotational('sda1')).to eq '0'
    end

    it 'returns nil when the device has no such attribute' do
      allow(File).to receive(:exist?).and_return(false)
      allow(File).to receive(:realpath).and_raise(Errno::ENOENT)
      expect(described_class.read_rotational('sdz')).to be_nil
    end
  end

  describe '.set_rotational' do
    before do
      allow(described_class).to receive(:rotational_path)
        .with('sda').and_return('/sys/block/sda/queue/rotational')
    end

    it 'writes the new value and reports one change' do
      allow(File).to receive(:read).and_return('1')
      expect(File).to receive(:write).with('/sys/block/sda/queue/rotational', '0')
      expect(described_class.set_rotational('sda', 0, 'VD 0 is SSD')).to eq 1
    end

    it 'is idempotent when the flag is already correct' do
      allow(File).to receive(:read).and_return('0')
      expect(File).to_not receive(:write)
      expect(described_class.set_rotational('sda', 0, 'VD 0 is SSD')).to eq 0
    end

    it 'logs what it changed and why' do
      allow(File).to receive(:read).and_return('1')
      allow(File).to receive(:write)
      expect(described_class).to receive(:log).with('sda: rotational 1 -> 0 (VD 0 is SSD)')
      described_class.set_rotational('sda', 0, 'VD 0 is SSD')
    end

    it 'reports no change when the attribute cannot be located' do
      allow(described_class).to receive(:rotational_path).with('sdz').and_return(nil)
      expect(File).to_not receive(:write)
      expect(described_class.set_rotational('sdz', 0, 'why')).to eq 0
    end

    it 'warns and survives a read-only sysfs' do
      allow(File).to receive(:read).and_return('1')
      allow(File).to receive(:write).and_raise(Errno::EACCES)
      expect(described_class).to receive(:log_warning).with(/cannot set rotational/)
      expect(described_class.set_rotational('sda', 0, 'why')).to eq 0
    end
  end

  describe '.apply' do
    before do
      allow(Dir).to receive(:glob).with('/sys/block/sd*')
                                  .and_return(%w(/sys/block/sda /sys/block/sdd /sys/block/sde /sys/block/sdl))
      { 'sda' => 0, 'sdd' => 3, 'sde' => 4, 'sdl' => 11 }.each do |dev, target|
        allow(described_class).to receive(:device_sysfs_path)
          .with("/sys/block/#{dev}").and_return(sysfs_path(target))
      end
    end

    it 'clears the flag on SSDs, including the ones whose DG differs from the VD' do
      allow(described_class).to receive(:set_rotational).and_return(1)
      expect(described_class).to receive(:set_rotational).with('sda', 0, 'VD 0 is SSD')
      expect(described_class).to receive(:set_rotational).with('sdd', 0, 'VD 3 is SSD')
      expect(described_class).to receive(:set_rotational).with('sdl', 0, 'VD 11 is SSD')
      described_class.apply(controllers)
    end

    it 'sets the flag on HDDs so the script is self-correcting' do
      allow(described_class).to receive(:set_rotational).and_return(1)
      expect(described_class).to receive(:set_rotational).with('sde', 1, 'VD 4 is HDD')
      described_class.apply(controllers)
    end

    it 'counts only the devices that actually changed' do
      # sda and sdd need changing; sde and sdl are already correct.
      allow(described_class).to receive(:set_rotational).and_return(1, 1, 0, 0)
      expect(described_class.apply(controllers)).to eq [2, 4]
    end

    it 'reports how many devices matched a virtual drive' do
      allow(described_class).to receive(:set_rotational).and_return(0)
      expect(described_class.apply(controllers)).to eq [0, 4]
    end

    it 'ignores physical drives exposed on a JBOD channel' do
      # Channel 0 target 11 is PD device id 11, not VD 11, so it must not be
      # looked up in the VD table.
      allow(described_class).to receive(:device_sysfs_path)
        .with('/sys/block/sda').and_return(sysfs_path(11, channel: 0))
      expect(described_class).to_not receive(:set_rotational).with('sda', anything, anything)
      allow(described_class).to receive(:set_rotational).and_return(0)
      expect(described_class.apply(controllers)[1]).to eq 3
    end

    it 'skips devices whose sysfs path cannot be resolved' do
      allow(described_class).to receive(:device_sysfs_path).and_return(nil)
      expect(described_class).to_not receive(:set_rotational)
      expect(described_class.apply(controllers)).to eq [0, 0]
    end

    it 'ignores disks behind a controller storcli did not report' do
      allow(described_class).to receive(:device_sysfs_path).with('/sys/block/sda')
                                                           .and_return(sysfs_path(0).sub(controller_pci, '0001:04:00.0'))
      allow(described_class).to receive(:set_rotational).and_return(0)
      expect(described_class).to_not receive(:set_rotational).with('sda', anything, anything)
      expect(described_class.apply(controllers)[1]).to eq 3
    end
  end

  describe '.propagate_to_device_mapper' do
    before do
      allow(Dir).to receive(:glob).with('/sys/block/dm-*').and_return(%w(/sys/block/dm-0))
    end

    it 'clears the flag on an LV whose backing devices are all SSDs' do
      allow(described_class).to receive(:dm_slaves).and_return(%w(sda sdb))
      allow(described_class).to receive(:read_rotational).and_return('0')
      expect(described_class).to receive(:set_rotational)
        .with('dm-0', 0, 'all backing devices are SSD').and_return(1)
      expect(described_class.propagate_to_device_mapper).to eq 1
    end

    it 'handles a PV that is a partition rather than a whole disk' do
      # /sys/block/dm-0/slaves holds partition names such as sda1, which have no
      # /sys/block entry; resolving them is what makes this case work.
      allow(described_class).to receive(:dm_slaves).and_return(%w(sda1))
      allow(described_class).to receive(:read_rotational).with('sda1').and_return('0')
      expect(described_class).to receive(:set_rotational)
        .with('dm-0', 0, anything).and_return(1)
      expect(described_class.propagate_to_device_mapper).to eq 1
    end

    it 'leaves an LV alone when any backing device is a spinner' do
      allow(described_class).to receive(:dm_slaves).and_return(%w(sda sde))
      allow(described_class).to receive(:read_rotational).with('sda').and_return('0')
      allow(described_class).to receive(:read_rotational).with('sde').and_return('1')
      expect(described_class).to_not receive(:set_rotational)
      expect(described_class.propagate_to_device_mapper).to eq 0
    end

    it 'leaves an LV alone when a backing device cannot be read' do
      allow(described_class).to receive(:dm_slaves).and_return(%w(sda1))
      allow(described_class).to receive(:read_rotational).with('sda1').and_return(nil)
      expect(described_class).to_not receive(:set_rotational)
      expect(described_class.propagate_to_device_mapper).to eq 0
    end

    it 'skips device-mapper nodes with no backing devices' do
      allow(described_class).to receive(:dm_slaves).and_return([])
      expect(described_class).to_not receive(:set_rotational)
      expect(described_class.propagate_to_device_mapper).to eq 0
    end
  end

  describe '.find_storcli' do
    it 'prefers the packaged MegaRAID path' do
      allow(File).to receive(:executable?).and_return(false)
      allow(File).to receive(:executable?).with('/opt/MegaRAID/storcli/storcli64').and_return(true)
      expect(described_class.find_storcli).to eq '/opt/MegaRAID/storcli/storcli64'
    end

    it 'finds the ppc64le package location without relying on PATH' do
      # The ppc64le RPM installs /usr/sbin/storcli; PATH is emptied here so a
      # hit can only have come from the built-in list.
      allow(File).to receive(:executable?).and_return(false)
      allow(File).to receive(:executable?).with('/usr/sbin/storcli').and_return(true)
      allow(ENV).to receive(:fetch).with('PATH', '').and_return('')
      expect(described_class.find_storcli).to eq '/usr/sbin/storcli'
    end

    it 'falls back to PATH for a location not in the built-in list' do
      allow(File).to receive(:executable?).and_return(false)
      allow(ENV).to receive(:fetch).with('PATH', '').and_return('/usr/bin:/usr/local/bin')
      allow(File).to receive(:executable?).with('/usr/local/bin/storcli64').and_return(true)
      expect(described_class.find_storcli).to eq '/usr/local/bin/storcli64'
    end

    it 'returns nil when storcli is not installed' do
      allow(File).to receive(:executable?).and_return(false)
      allow(ENV).to receive(:fetch).with('PATH', '').and_return('/usr/bin')
      expect(described_class.find_storcli).to be_nil
    end
  end

  describe '.storcli_data' do
    let(:success) do
      instance_double(Mixlib::ShellOut, error?: false, stdout: storcli_data.to_json)
    end

    it 'invokes storcli with JSON output, no shell interpolation and a timeout' do
      expect(described_class).to receive(:shell_out)
        .with('/opt/MegaRAID/storcli/storcli64', '/call', 'show', 'all', 'J', timeout: 30)
        .and_return(success)
      described_class.storcli_data('/opt/MegaRAID/storcli/storcli64')
    end

    it 'parses the JSON payload' do
      allow(described_class).to receive(:shell_out).and_return(success)
      expect(described_class.storcli_data('storcli64')).to eq storcli_data
    end

    it 'warns and returns nil when storcli exits non-zero' do
      allow(described_class).to receive(:shell_out)
        .and_return(instance_double(Mixlib::ShellOut, error?: true, stdout: ''))
      expect(described_class).to receive(:log_warning).with(/no usable data/)
      expect(described_class.storcli_data('storcli64')).to be_nil
    end

    it 'returns nil when storcli produces no output' do
      allow(described_class).to receive(:shell_out)
        .and_return(instance_double(Mixlib::ShellOut, error?: false, stdout: "\n"))
      expect(described_class.storcli_data('storcli64')).to be_nil
    end

    it 'returns nil on malformed JSON rather than raising' do
      allow(described_class).to receive(:shell_out)
        .and_return(instance_double(Mixlib::ShellOut, error?: false, stdout: 'not json'))
      expect(described_class).to receive(:log_warning).with(/could not parse storcli output/)
      expect(described_class.storcli_data('storcli64')).to be_nil
    end

    it 'returns nil when storcli cannot be executed at all' do
      allow(described_class).to receive(:shell_out).and_raise(Errno::ENOENT)
      expect(described_class).to receive(:log_warning).with(/could not run/)
      expect(described_class.storcli_data('storcli64')).to be_nil
    end
  end

  describe '.run' do
    context 'on a host with no MegaRAID controller' do
      before { allow(Dir).to receive(:exist?).with('/sys/module/megaraid_sas').and_return(false) }

      it 'succeeds without touching anything, so it is safe fleet-wide' do
        expect(described_class).to_not receive(:find_storcli)
        expect(described_class).to receive(:log).with(/megaraid_sas not loaded/)
        expect(described_class.run).to eq 0
      end
    end

    context 'when a controller is present but storcli is missing' do
      before do
        allow(Dir).to receive(:exist?).with('/sys/module/megaraid_sas').and_return(true)
        allow(described_class).to receive(:find_storcli).and_return(nil)
      end

      it 'warns but still succeeds, so it cannot abort a Chef converge' do
        # This is the x86 case: osl-nrpe installs MegaCli there, not storcli. A
        # non-zero exit would fail systemctl start and raise in the Chef run.
        expect(described_class).to receive(:log_warning).with(/storcli is not installed/)
        expect(described_class.run).to eq 0
      end
    end

    context 'with a working controller' do
      before do
        allow(Dir).to receive(:exist?).with('/sys/module/megaraid_sas').and_return(true)
        allow(described_class).to receive(:find_storcli).and_return('/usr/sbin/storcli64')
      end

      it 'succeeds when storcli data is unusable' do
        allow(described_class).to receive(:storcli_data).and_return(nil)
        expect(described_class.run).to eq 0
      end

      it 'warns when no controller could be identified from the data' do
        allow(described_class).to receive(:storcli_data).and_return('Controllers' => [])
        expect(described_class).to_not receive(:apply)
        expect(described_class).to receive(:log_warning).with(/no controller could be identified/)
        expect(described_class.run).to eq 0
      end

      it 'warns when controllers were found but no device matched one' do
        # Without this the operator sees "0 device(s) updated", which is
        # indistinguishable from a healthy no-op.
        allow(described_class).to receive(:storcli_data).and_return(storcli_data)
        allow(described_class).to receive(:apply).and_return([0, 0])
        allow(described_class).to receive(:propagate_to_device_mapper).and_return(0)
        expect(described_class).to receive(:log_warning).with(/no block device could be matched/)
        expect(described_class.run).to eq 0
      end

      it 'applies the flags and reports the total' do
        allow(described_class).to receive(:storcli_data).and_return(storcli_data)
        allow(described_class).to receive(:apply).and_return([4, 4])
        allow(described_class).to receive(:propagate_to_device_mapper).and_return(2)
        expect(described_class).to_not receive(:log_warning)
        expect(described_class).to receive(:log).with('6 device(s) updated')
        expect(described_class.run).to eq 0
      end
    end
  end
end
