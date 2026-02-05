control 'radosgw' do
  describe command('ceph -s') do
    its('stdout') { should match(/rgw: 1 daemon active \(1 hosts, 1 zones\)/) }
  end

  describe package 'ceph-radosgw' do
    it { should be_installed }
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
