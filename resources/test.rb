resource_name :osl_ceph_test
provides :osl_ceph_test
default_action :start
unified_mode true

property :cephfs, [true, false], default: false
property :osd_size, String, default: '1G'

action :start do
  osl_ceph_install 'test' do
    mds new_resource.cephfs
    mgr true
    mon true
    osd true
  end

  osl_ceph_config 'test' do
    fsid 'ae3f1d03-bacd-4a90-b869-1a4fabb107f2'
    mon_initial_members [node['hostname']]
    mon_host [node['ipaddress']]
    public_network %w(
      10.1.100.0/23
    )
    cluster_network %w(
      10.1.100.0/23
    )
  end

  osl_ceph_mon 'test'

  osl_ceph_mgr 'test'

  template '/var/tmp/crush_map_decompressed' do
    cookbook 'osl-ceph'
  end

  # This allows us to make ceph happy on a single node for testing
  execute 'update crush map' do
    cwd '/var/tmp'
    command <<-EOC
      crushtool -c crush_map_decompressed -o new_crush_map_compressed
      ceph osd setcrushmap -i new_crush_map_compressed
      touch /var/tmp/new_crush_map_compressed.done
    EOC
    creates '/var/tmp/new_crush_map_compressed.done'
  end

  # Create fake OSD disks using files
  %w(0 1 2).each do |i|
    execute "create osd#{i}" do
      command <<~EOC
        dd if=/dev/zero of=/root/osd#{i} bs=#{new_resource.osd_size} count=1
        vgcreate osd#{i} $(losetup --show -f /root/osd#{i})
        lvcreate -n osd#{i} -l 100%FREE osd#{i}
        ceph-volume lvm create --bluestore --data osd#{i}/osd#{i}
      EOC
      not_if "vgs osd#{i}"
    end
  end

  if new_resource.cephfs
    osl_ceph_mds 'mds'

    execute 'create cephfs' do
      command <<~EOC
        ceph osd pool create cephfs_data 32
        ceph osd pool create cephfs_metadata 32
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
  end
end
