control 'monitoring' do
  describe file('/etc/ceph/ceph.client.nagios.keyring') do
    its('owner') { should eq 'nrpe' }
    its('group') { should eq 'nrpe' }
    its('mode') { should cmp '0640' }
    its('content') { should match(/^\[client\.nagios\]$/) }
  end

  describe etc_group.where(name: 'ceph') do
    its('users') { should include 'nrpe' }
  end

  %w(
    check_ceph_mon
    check_ceph_osd
  ).each do |check|
    describe command("/usr/lib64/nagios/plugins/check_nrpe -H 127.0.0.1 -c #{check}") do
      its('exit_status') { should eq 0 }
    end
  end

  describe command('/usr/lib64/nagios/plugins/check_ceph_df -W 80 -C 90') do
    its('exit_status') { should eq 0 }
  end

  describe command('/usr/lib64/nagios/plugins/check_ceph_health') do
    its('exit_status') { should eq 0 }
  end
end
