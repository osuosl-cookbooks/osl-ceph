%w(cephfs_data cephfs_metadata).each do |p|
  ceph_chef_pool p do
    pg_num node['ceph_test']['pg_num']
    pgp_num node['ceph_test']['pg_num']
  end
end
