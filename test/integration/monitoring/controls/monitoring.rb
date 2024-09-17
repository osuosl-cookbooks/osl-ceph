%w(
  check_ceph_mon
  check_ceph_osd
  check_ceph_rgw
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
