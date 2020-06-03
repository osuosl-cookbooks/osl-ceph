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

osl_cephfs 'umount /mnt/bar' do
  name '/mnt/bar' # rubocop:disable ChefCorrectness/ResourceSetsNameProperty
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
