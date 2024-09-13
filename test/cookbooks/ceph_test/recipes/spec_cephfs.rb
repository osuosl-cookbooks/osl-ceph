osl_cephfs '/mnt/ceph' do
  key 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ=='
  client_name 'cephfs'
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
