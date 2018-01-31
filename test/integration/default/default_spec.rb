describe package('ceph') do
  it { should be_installed }
  its('version') { should cmp < '13.0.0' }
end

describe command('ceph --version') do
  its('exit_status') { should eq 0 }
  its('stdout') { should include 'luminous' }
end

describe yum.repo('ceph') do
  it { should exist }
  it { should be_enabled }
end
