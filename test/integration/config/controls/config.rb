keyring = input('keyring')

control 'config' do
  describe file('/etc/ceph') do
    its('owner') { should eq 'ceph' }
    its('group') { should eq 'ceph' }
    its('mode') { should cmp '0750' }
  end

  describe file '/etc/ceph/ceph.conf' do
    its('owner') { should eq 'ceph' }
    its('group') { should eq 'ceph' }
  end

  describe ini '/etc/ceph/ceph.conf' do
    its('global.cluster network') { should eq '10.1.100.0/23' }
    its('global.fsid') { should eq 'ae3f1d03-bacd-4a90-b869-1a4fabb107f2' }
    its('global.mon host') { should match /10\.1\.100\.[0-9]+/ }
    its('global.mon initial members') { should eq 'node1' }
    its('global.public network') { should eq '10.1.100.0/23' }
  end

  if keyring
    describe file('/etc/ceph/ceph.client.test.keyring') do
      its('owner') { should eq 'ceph' }
      its('group') { should eq 'ceph' }
      its('mode') { should cmp '0600' }
      its('content') { should match(/\[client.test\]\n\tkey = AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==\n/) }
    end

    describe file('/tmp/test2-filename') do
      its('owner') { should eq 'nobody' }
      its('group') { should eq 'nobody' }
      its('mode') { should cmp '0600' }
      its('content') { should match(/\[test2-name\]\n\tkey = AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==\n/) }
    end

    describe file('/etc/ceph/ceph.client.delete.keyring') do
      it { should_not exist }
    end
  end
end
