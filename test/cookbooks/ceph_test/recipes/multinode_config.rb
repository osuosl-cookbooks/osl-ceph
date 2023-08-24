if ::File.exist?("/var/lib/ceph/mon/ceph-#{node['hostname']}/done")
  init_members %w(
    node1
    node2
    node3
  )
  hosts %w(
    192.168.30.10
    192.168.30.11
    192.168.30.12
  )
else
  init_members %w(
    node1
  )
  hosts %w(
    192.168.30.10
  )
end

osl_ceph_config 'multinode' do
  fsid '78acef73-54bf-481d-ad7c-130571ea6750'
  mon_initial_members init_members
  mon_host hosts
  public_network %w(
    192.168.30.0/24
  )
  cluster_network %w(
    192.168.30.0/24
  )
end
