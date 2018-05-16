%w(
  check_ceph_df
  check_ceph_health
  check_ceph_mds
  check_ceph_mon
  check_ceph_osd
  check_ceph_rgw
).each do |plugin|
  describe command("/usr/lib64/nagios/plugins/#{plugin} -h") do
    its('exit_status') { should eq 0 }
  end
end
