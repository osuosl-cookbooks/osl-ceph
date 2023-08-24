control 'ceph_nodes' do
  describe package('ceph-common') do
    it { should be_installed }
    its('version') { should cmp < '14.0.0' }
  end

  describe command('ceph --version') do
    its('exit_status') { should eq 0 }
    its('stdout') { should include 'mimic' }
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

  describe command('ceph health') do
    its('stdout') { should match(/^HEALTH_OK$/) }
  end

  describe command('ceph -s') do
    its('stdout') { should match(/mon: 3 daemons, quorum node[0-9],node[0-9],node[0-9]/) }
    its('stdout') { should match(/mgr: node[0-9]\(active\), standbys: node[0-9], node[0-9]/) }
  end

  describe command('ceph osd stat') do
    its('stdout') { should match(/^9 osds: 9 up, 9 in;/) }
  end

  describe command('ceph mds stat') do
    its('stdout') { should match(%(^cephfs-1/1/1 up  {0=node[0-9]=up:active}, 2 up:standby$)) }
  end

  describe port('6789') do
    it { should be_listening }
    its('processes') { should include 'ceph-mon' }
  end

  describe command('ss -tpln') do
    its('stdout') { should include 'ceph-osd' }
    its('stdout') { should include 'ceph-mds' }
  end

  %w(
    ceph-mds.target
    ceph-mgr.target
    ceph-mon.target
    ceph-osd.target
  ).each do |s|
    describe service(s) do
      it { should be_installed }
      it { should be_enabled }
      it { should be_running }
    end
  end
end
