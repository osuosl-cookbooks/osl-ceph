osl_ceph_test 'mds' do
  cephfs true
  radosgw node['ceph_test']['radosgw']
end

ceph_chef_client 'cephfs' do
  keyname 'client.cephfs'
  caps(
    mon: 'allow r',
    osd: 'allow rw pool=cephfs_data',
    mds: 'allow rw'
  )
  key 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ=='
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
end

osl_cephfs '/mnt/foo' do
  key 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ=='
  subdir '/foo'
  client_name 'cephfs'
end
