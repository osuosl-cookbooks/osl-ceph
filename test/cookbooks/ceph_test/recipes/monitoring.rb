ceph_chef_client 'nagios' do
  caps(
    'mon' => 'allow r'
  )
  key 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ=='
  keyname 'client.nagios'
end
