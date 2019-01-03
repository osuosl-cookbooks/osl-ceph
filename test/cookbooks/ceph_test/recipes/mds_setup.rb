execute 'ceph fs new cephfs cephfs_metadata cephfs_data' do
  not_if 'ceph fs get cephfs'
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

ruby_block 'wait for ceph mds cluster' do
  block do
    puts ''
    loop do
      ceph_health = `ceph -s`
      break if %r{mds: cephfs-1/1/1 up  \{0=node1=up:active\}} =~ ceph_health
      puts 'Ceph MDS not ready ...'
      sleep(1)
    end
  end
end
