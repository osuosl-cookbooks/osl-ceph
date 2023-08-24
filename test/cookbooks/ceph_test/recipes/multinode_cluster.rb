case node['hostname']
when 'node1'
  ip = '10.1.2.10'
when 'node2'
  ip = '10.1.2.11'
when 'node3'
  ip = '10.1.2.12'
end

include_recipe 'ceph_test::multinode_network'

osl_ceph_install 'multinode' do
  mds true
  mgr true
  mon true
  osd true
end

if ::File.exist?("/var/lib/ceph/mon/ceph-#{node['hostname']}/done")
  init_members = %w(
    node1
    node2
    node3
  )
  hosts = %w(
    10.1.2.10
    10.1.2.11
    10.1.2.12
  )
else
  case node['hostname']
  when 'node1'
    init_members = %w(
      node1
    )
    hosts = %w(
      10.1.2.10
    )
  when 'node2'
    init_members = %w(
      node1
      node2
    )
    hosts = %w(
      10.1.2.10
      10.1.2.11
    )
  when 'node3'
    init_members = %w(
      node1
      node2
      node3
    )
    hosts = %w(
      10.1.2.10
      10.1.2.11
      10.1.2.12
    )
  end
end

osl_ceph_config 'multinode' do
  fsid '78acef73-54bf-481d-ad7c-130571ea6750'
  mon_initial_members init_members
  mon_host hosts
  public_network %w(
    10.1.2.0/24
  )
  cluster_network %w(
    10.1.2.0/24
  )
end

osl_ceph_mon 'multinode' do
  ipaddress ip
  mon_key 'AQBkf+ZkFIMSLxAAnYRXnc/CaUdHChGCxyH3IQ=='
  admin_key 'AQBkf+Zkw67WNBAAzK7M8SnedPLkYXIanbWNCg=='
  bootstrap_key 'AQBkf+Zk+GsrOxAA1xYwZeLRB5gLI42lmjGV+A=='
  generate_monmap false
end

osl_ceph_mgr 'multinode'

# Create fake OSD disks using files
%w(0 1 2).each do |i|
  execute "create osd#{i}" do
    command <<~EOC
      dd if=/dev/zero of=/root/osd#{i} bs=1G count=1
      vgcreate osd#{i} $(losetup --show -f /root/osd#{i})
      lvcreate -n osd#{i} -l 100%FREE osd#{i}
      ceph-volume lvm create --bluestore --data osd#{i}/osd#{i}
    EOC
    not_if "vgs osd#{i}"
  end
end

osl_ceph_mds 'mds'
