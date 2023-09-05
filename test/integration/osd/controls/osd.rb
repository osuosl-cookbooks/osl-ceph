control 'osd' do
  describe command('ceph osd stat') do
    its('stdout') { should match(/^3 osds: 3 up.*, 3 in/) }
  end

  describe command('ss -tpln') do
    its('stdout') { should include 'ceph-osd' }
  end

  describe service('ceph-osd.target') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
