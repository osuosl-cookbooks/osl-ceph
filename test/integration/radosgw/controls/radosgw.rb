control 'radosgw' do
  describe command('ceph -s') do
    its('stdout') { should match(/rgw: 1 daemon active \(1 hosts, 1 zones\)/) }
  end

  describe package 'ceph-radosgw' do
    it { should be_installed }
  end

  describe ini '/etc/ceph/ceph.conf' do
    its(['client.rgw.node1', 'host']) { should eq 'node1' }
    its(['client.rgw.node1', 'keyring']) { should eq '/var/lib/ceph/radosgw/ceph-node1/keyring' }
    its(['client.rgw.node1', 'rgw frontends']) { should eq '"beast port=8080"' }
  end

  describe file('/etc/ceph/ceph.rgw.node1.keyring') do
    it { should be_symlink }
    its('link_path') { should eq '/var/lib/ceph/radosgw/ceph-node1/keyring' }
  end

  describe port 8080 do
    it { should be_listening }
    its('processes') { should include 'notif-worker0' }
  end

  %w(ceph-radosgw@rgw.node1.service ceph-radosgw.target).each do |s|
    describe service(s) do
      it { should be_installed }
      it { should be_enabled }
      it { should be_running }
    end
  end

  describe command 'ceph df' do
    its('stdout') { should match /\.rgw\.root/ }
    its('stdout') { should match /default\.rgw\.control/ }
    its('stdout') { should match /default\.rgw\.meta/ }
    its('stdout') { should match /default\.rgw\.log/ }
  end
end
