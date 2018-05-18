ceph_keyring 'test' do
  key 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ=='
end

ceph_keyring 'test2' do
  key 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ=='
  key_name 'test2-name'
  key_filename 'test2-filename'
  owner 'nobody'
  group 'nobody'
  chef_dir '/tmp'
end

ceph_keyring 'delete' do
  action :delete
end
