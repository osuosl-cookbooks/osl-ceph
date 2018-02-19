describe command('ceph health') do
  its('stdout') { should match(/^HEALTH_OK$/) }
end

describe command('ceph -s') do
  its('stdout') { should match(/mon: 1 daemons, quorum node1/) }
end

describe port('6789') do
  it { should be_listening }
  its('processes') { should include 'ceph-mon' }
end

%w(ceph-mon@node1.service ceph-mon.target).each do |s|
  describe service(s) do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
