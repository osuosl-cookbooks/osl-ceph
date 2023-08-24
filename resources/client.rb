resource_name :osl_ceph_client
provides :osl_ceph_client
# backwards compatible old name
provides :ceph_chef_client
unified_mode true
default_action :add

property :as_keyring, [true, false], default: true
property :caps, Hash, default: { 'mon' => 'allow r', 'osd' => 'allow r' }
property :filename, String
property :group, String, default: 'root'
property :keyname, String
property :key, String, sensitive: true
property :mode, [Integer, String], default: '0644'
property :owner, String, default: 'root'

action :add do
  unless ceph_auth_exists?(ceph_keyname)
    converge_by("Creating ceph auth for #{ceph_keyname}") do
      ceph_create_entity(ceph_keyname)
    end
  end

  file ceph_key_filename do
    content ceph_file_content(ceph_keyname, ceph_key, new_resource.as_keyring)
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
    sensitive true
  end
end
