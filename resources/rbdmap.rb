resource_name :osl_ceph_rbdmap
provides :osl_ceph_rbdmap
default_action :create
unified_mode true

property :id, String, required: [:create]
property :image, String, name_property: true
property :pool, String, required: true

action :create do
  append_if_no_line "Create #{new_resource.pool}/#{new_resource.image} mapping" do
    path '/etc/ceph/rbdmap'
    line "#{new_resource.pool}/#{new_resource.image} id=#{new_resource.id},keyring=/etc/ceph/ceph.client.#{new_resource.id}.keyring"
  end

  service 'rbdmap' do
    action :enable
  end
end

action :remove do
  delete_lines "Remove #{new_resource.pool}/#{new_resource.image} mapping" do
    path '/etc/ceph/rbdmap'
    pattern %r{^#{new_resource.pool}/#{new_resource.image}.*}
  end
end
