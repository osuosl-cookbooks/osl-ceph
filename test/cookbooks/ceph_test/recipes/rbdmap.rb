osl_ceph_rbdmap 'image' do
  pool 'pool'
  id 'image'
end

osl_ceph_rbdmap 'delete' do
  pool 'pool'
  action :remove
end
