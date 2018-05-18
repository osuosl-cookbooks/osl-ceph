describe package('ceph') do
  it { should be_installed }
  its('version') { should cmp < '13.0.0' }
end

describe command('ceph --version') do
  its('exit_status') { should eq 0 }
  its('stdout') { should include 'luminous' }
end

describe file('/etc/ceph') do
  its('owner') { should eq 'ceph' }
  its('group') { should eq 'ceph' }
  its('mode') { should cmp '0750' }
end

describe yum.repo('ceph') do
  it { should exist }
  it { should be_enabled }
end

describe file('/etc/ceph/ceph.client.test.keyring') do
  its('owner') { should eq 'ceph' }
  its('group') { should eq 'ceph' }
  its('mode') { should cmp '0600' }
  its('content') { should match(/\[client.test\]\n\tkey = AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==\n/) }
end

describe file('/tmp/test2-filename') do
  its('owner') { should eq 'nobody' }
  its('group') { should eq 'nobody' }
  its('mode') { should cmp '0600' }
  its('content') { should match(/\[test2-name\]\n\tkey = AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==\n/) }
end

describe file('/etc/ceph/ceph.client.delete.keyring') do
  it { should_not exist }
end
