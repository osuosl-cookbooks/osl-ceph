execute 'create cephfs' do
  command <<~EOC
    ceph osd pool create cephfs_data 64
    ceph osd pool create cephfs_metadata 64
    ceph fs new cephfs cephfs_metadata cephfs_data
    touch /root/cephfs.done
  EOC
  creates '/root/cephfs.done'
end

ruby_block 'wait for ceph mds cluster' do
  block do
    puts ''
    loop do
      ceph_health = `ceph -s`
      break if %r{mds: cephfs-1/1/1 up  \{0=node[0-9]=up:active\}} =~ ceph_health
      puts 'Ceph MDS not ready ...'
      sleep(1)
    end
  end
  not_if { ::File.exist?('/root/ceph-mds.done') }
end

file '/root/ceph-mds.done'

osl_ceph_client 'cephfs' do
  keyname 'client.cephfs'
  caps(
    mon: 'allow r',
    osd: 'allow rw pool=cephfs_data',
    mds: 'allow rw'
  )
  key 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ=='
end
