include_recipe 'ceph_test::multinode_network'

osl_ceph_install 'client'

osl_ceph_config 'multinode' do
  fsid '78acef73-54bf-481d-ad7c-130571ea6750'
  mon_initial_members %w(
    node1
    node2
    node3
  )
  mon_host %w(
    10.1.2.10
    10.1.2.11
    10.1.2.12
  )
  public_network %w(
    10.1.2.0/24
  )
  cluster_network %w(
    10.1.2.0/24
  )
end

osl_cephfs '/mnt/ceph' do
  key 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ=='
  client_name 'cephfs'
end

directory '/mnt/ceph/bar'
directory '/mnt/ceph/foo'

file '/mnt/ceph/bar/foo' do
  content 'barfoo'
end

file '/mnt/ceph/foo/bar' do
  content 'foobar'
end

osl_cephfs '/mnt/bar' do
  key 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ=='
  subdir '/bar'
  client_name 'cephfs'
  action :umount
end

osl_cephfs '/mnt/foo' do
  key 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ=='
  subdir '/foo'
  client_name 'cephfs'
end
