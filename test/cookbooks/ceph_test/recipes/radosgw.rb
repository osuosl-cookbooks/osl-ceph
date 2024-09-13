osl_ceph_test 'radosgw' do
  radosgw true
end

osl_ceph_radosgw 'radosgw' do
  subscribes :restart, 'osl_ceph_test[radosgw]'
end
