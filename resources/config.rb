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
property :rgw_dns_name, String, default: lazy { node['fqdn'] }

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
      client_options: new_resource.client_options,
      cluster_network: new_resource.cluster_network.join(','),
      fsid: new_resource.fsid,
      mon_host: new_resource.mon_host.join(','),
      mon_initial_members: new_resource.mon_initial_members.join(','),
      public_network: new_resource.public_network.join(','),
      radosgw: new_resource.radosgw,
      rgw_dns_name: new_resource.rgw_dns_name
    )
    cookbook 'osl-ceph'
  end
end
