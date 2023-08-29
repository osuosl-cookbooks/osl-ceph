include_recipe 'ceph_test::default'

osl_ceph_install 'mon' do
  mon true
end

osl_ceph_mon 'mon'
