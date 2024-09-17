resource_name :osl_ceph_config
provides :osl_ceph_config
default_action :create
unified_mode true

property :fsid, String, required: true
property :mon_initial_members, Array, required: true
property :mon_host, Array, required: true
property :public_network, Array, required: true
property :cluster_network, Array, required: true
property :client_options, Array, default: ['admin socket = /var/run/ceph/$cluster-$type.$id.asok']
property :radosgw, [true, false], default: false

action :create do
  directory '/etc/ceph' do
    owner 'ceph'
    group 'ceph'
    mode '0750'
  end

  template '/etc/ceph/ceph.conf' do
    owner 'ceph'
    group 'ceph'
    variables(
      fsid: new_resource.fsid,
      mon_initial_members: new_resource.mon_initial_members.join(','),
      mon_host: new_resource.mon_host.join(','),
      public_network: new_resource.public_network.join(','),
      cluster_network: new_resource.cluster_network.join(','),
      client_options: new_resource.client_options,
      radosgw: new_resource.radosgw
    )
    cookbook 'osl-ceph'
  end
end
