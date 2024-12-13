osl_ceph_install 'default'

osl_ceph_config 'default' do
  fsid 'ae3f1d03-bacd-4a90-b869-1a4fabb107f2'
  mon_initial_members [node['hostname']]
  mon_host [node['ipaddress']]
  public_network %w(
    10.0.0.0/8
  )
  cluster_network %w(
    10.0.0.0/8
  )
end

include_recipe 'ceph_test::ceph_keyring'
