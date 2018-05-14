# Create wal and blk devices
chef_gem 'fog-openstack' do
  compile_time true
end

vm_uuid = File.read('/run/cloud-init/.instance-id').strip

template '/root/volume.rb' do
  source 'volume.rb.erb'
  sensitive true
  mode '750'
  variables(vm_uuid: vm_uuid)
end

execute 'create volumes' do
  command '/root/volume.rb'
  live_stream true
  creates '/dev/sdf'
end

# Format wal and blk devices
('b'..'c').to_a.each do |i|
  execute "create ssd#{i}" do
    command <<-EOF
      parted --script /dev/sd#{i} \
        mklabel gpt \
        mkpart primary 1MiB 512MiB \
        mkpart primary 512MiB 1Gib \
        mkpart primary 1Gib 1.5Gib \
        mkpart primary 1.5Gib 2Gib
    EOF
    creates "/dev/sd#{i}1"
  end
end

# Create OSD devices
('d'..'f').to_a.each do |i|
  execute "create osd#{i}" do
    command <<-EOF
      parted --script /dev/sd#{i} \
        mklabel gpt \
        mkpart primary 1 100%
    EOF
    creates "/dev/sd#{i}1"
  end
end
