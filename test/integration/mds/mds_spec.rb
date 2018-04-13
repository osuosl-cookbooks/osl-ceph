describe command('ceph mds stat') do
  its('stdout') { should match(%(^cephfs-1/1/1 up  {0=node1=up:active}$)) }
end

describe command('ss -tpln') do
  its('stdout') { should include 'ceph-mds' }
end

describe service('ceph-mds.target') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe mount('/mnt/ceph') do
  it { should be_mounted }
  its('device') { should eq 'ceph-fuse' }
  its('type') { should eq 'fuse.ceph-fuse' }
  its('options') { should eq ['rw', 'relatime', 'user_id=0', 'group_id=0', 'allow_other'] }
end
