include_recipe 'ceph_test::mon'

osl_ceph_install 'mgr' do
  mgr true
end

osl_ceph_mgr 'mgr' do
  subscribes :restart, 'osl_ceph_config[default]'
end
