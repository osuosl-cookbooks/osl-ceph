include_recipe 'ceph_test::default'

osl_ceph_install 'mon' do
  mon true
end

osl_ceph_mon 'mon' do
  mon_key 'AQBkf+ZkFIMSLxAAnYRXnc/CaUdHChGCxyH3IQ=='
  admin_key 'AQBkf+Zkw67WNBAAzK7M8SnedPLkYXIanbWNCg=='
  bootstrap_key 'AQBkf+Zk+GsrOxAA1xYwZeLRB5gLI42lmjGV+A=='
  generate_monmap false
end
