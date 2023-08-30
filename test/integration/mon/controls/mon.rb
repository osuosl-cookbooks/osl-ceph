control 'mon' do
  describe command('ceph health') do
    its('stdout') { should match(/^(HEALTH_OK|HEALTH_WARN OSD count 0 < osd_pool_default_size 3)/) }
  end

  describe command('ceph -s') do
    its('stdout') { should match(/mon: 1 daemons, quorum node1/) }
  end

  # v2 msgr2 port
  describe port('3300') do
    it { should be_listening }
    its('processes') { should include 'ceph-mon' }
  end

  # v1 legacy port
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
end
