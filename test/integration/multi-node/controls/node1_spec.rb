control 'node1' do
  %w(
    ceph-mon@node1.service
    ceph-mgr@node1.service
    ceph-mds@node1.service
    ceph-radosgw@rgw.node1.service
  ).each do |s|
    describe service(s) do
      it { should be_installed }
      it { should be_enabled }
      it { should be_running }
    end
  end
  describe command('ss -tpln') do
    its('stdout') { should include 'ceph-mgr' }
  end
end
