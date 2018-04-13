execute 'ceph fs new cephfs cephfs_metadata cephfs_data' do
  not_if 'ceph fs get cephfs'
end

ceph_chef_cephfs '/mnt/ceph' do
  action [:enable, :mount]
end
