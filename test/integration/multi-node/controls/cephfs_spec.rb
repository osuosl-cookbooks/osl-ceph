case os.release.to_i
when 8
  mount_opts = ['rw', 'relatime', 'seclabel', 'name=cephfs', 'secret=<hidden>', 'fsid=78acef73-54bf-481d-ad7c-130571ea6750', 'acl', '_netdev']
when 9
  mount_opts = ['rw', 'relatime', 'seclabel', 'name=cephfs', 'secret=<hidden>', 'fsid=78acef73-54bf-481d-ad7c-130571ea6750', 'acl']
end

control 'cephfs_client' do
  describe file('/etc/ceph/ceph.client.cephfs.secret') do
    its('content') { should match /^AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==$/ }
    its('mode') { should cmp '0600' }
  end

  %w(/mnt/ceph /mnt/ceph/bar /mnt/foo).each do |d|
    describe file(d) do
      it { should be_directory }
    end
  end

  describe file '/mnt/bar' do
    it { should_not exist }
  end

  describe mount('/mnt/ceph') do
    it { should be_mounted }
    its('device') { should match '10.1.2.10,10.1.2.11,10.1.2.12:/' }
    its('type') { should eq 'ceph' }
    its('options') { should eq mount_opts }
  end

  describe mount('/mnt/foo') do
    it { should be_mounted }
    its('device') { should match '10.1.2.10,10.1.2.11,10.1.2.12:/foo' }
    its('type') { should eq 'ceph' }
    its('options') { should eq mount_opts }
  end

  describe mount('/mnt/bar') do
    it { should_not be_mounted }
  end

  describe etc_fstab.where { mount_point == '/mnt/ceph' } do
    its('device_name') { should match ['10.1.2.10,10.1.2.11,10.1.2.12:/'] }
    its('file_system_type') { should eq ['ceph'] }
    its('mount_options') { should eq [['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret']] }
    its('dump_options') { should cmp 0 }
  end

  describe etc_fstab.where { mount_point == '/mnt/foo' } do
    its('device_name') { should match ['10.1.2.10,10.1.2.11,10.1.2.12:/foo'] }
    its('file_system_type') { should eq ['ceph'] }
    its('mount_options') { should eq [['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret']] }
    its('dump_options') { should cmp 0 }
  end

  describe etc_fstab.where { mount_point == '/mnt/bar' } do
    it { should_not be_configured }
  end

  describe file('/mnt/ceph/bar/foo') do
    its('content') { should cmp 'barfoo' }
  end

  describe file('/mnt/ceph/foo/bar') do
    its('content') { should cmp 'foobar' }
  end

  describe file('/mnt/bar/foo') do
    it { should_not exist }
  end

  describe file('/mnt/foo/bar') do
    its('content') { should cmp 'foobar' }
  end
end
