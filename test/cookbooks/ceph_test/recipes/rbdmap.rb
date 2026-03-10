osl_ceph_rbdmap 'image' do
  pool 'pool'
  id 'image'
end

osl_ceph_rbdmap 'image_with_options' do
  pool 'pool'
  id 'image'
  options 'queue_depth=64'
end

osl_ceph_rbdmap 'delete' do
  pool 'pool'
  action :remove
end
