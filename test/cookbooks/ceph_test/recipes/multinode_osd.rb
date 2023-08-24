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
