%w(
  check_ceph_df
  check_ceph_health
  check_ceph_mon
  check_ceph_osd
).each do |check|
  describe command("/usr/lib64/nagios/plugins/check_nrpe -H 127.0.0.1 -c #{check}") do
    its('exit_status') { should eq 0 }
  end
end
