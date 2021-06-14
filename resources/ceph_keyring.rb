resource_name :ceph_keyring
provides :ceph_keyring
unified_mode true
default_action :create

property :key, String, required: [:create]
property :key_name, [String, nil]
property :key_filename, [String, nil]
property :owner, String, default: node['ceph']['owner']
property :group, String, default: node['ceph']['group']
property :chef_dir, String, default: '/etc/ceph'

action :create do
  key_name = new_resource.key_name.nil? ? "client.#{new_resource.name}" : new_resource.key_name
  key_filename = new_resource.key_filename.nil? ? "ceph.client.#{new_resource.name}.keyring" : new_resource.key_filename

  file "#{new_resource.chef_dir}/#{key_filename}" do
    content "[#{key_name}]\n\tkey = #{new_resource.key}\n"
    sensitive true
    owner new_resource.owner
    group new_resource.group
    mode '0600'
  end
end

action :delete do
  key_filename = new_resource.key_filename.nil? ? "ceph.client.#{new_resource.name}.keyring" : new_resource.key_filename
  file "#{new_resource.chef_dir}/#{key_filename}" do
    sensitive true
    action :delete
  end
end
