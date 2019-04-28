control 'node3' do
  %w(
    ceph-mon@node3.service
    ceph-mds@node3.service
  ).each do |s|
    describe service(s) do
      it { should be_installed }
      it { should be_enabled }
      it { should be_running }
    end
  end
  describe command('ss -tpln') do
    its('stdout') { should_not include 'ceph-mgr' }
  end
end
