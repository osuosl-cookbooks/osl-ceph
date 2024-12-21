control 'mgr' do
  describe command('ceph -s') do
    its('stdout') { should match(/mgr: node1\(active/) }
  end

  %w(
    ceph-mgr
    ceph-mgr-dashboard
  ).each do |p|
    describe package p do
      it { should be_installed }
    end
  end

  describe command('ss -tpln') do
    its('stdout') { should include 'ceph-mgr' }
  end

  %w(ceph-mgr@node1.service ceph-mgr.target).each do |s|
    describe service(s) do
      it { should be_installed }
      it { should be_enabled }
      it { should be_running }
    end
  end
end
