describe command('ceph -s') do
  its('stdout') { should match(/mgr: node1\(active\)/) }
end

describe port('6800') do
  it { should be_listening }
  its('processes') { should include 'ceph-mgr' }
end

%w(ceph-mgr@node1.service ceph-mgr.target).each do |s|
  describe service(s) do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
