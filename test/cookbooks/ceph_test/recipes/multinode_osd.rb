# Add OSDs
%w(
  sdb
  sdc
  sdd
).each do |d|
  execute "create osd on #{d}" do
    command <<~EOC
      ceph-volume lvm create --bluestore --data /dev/#{d}
      touch /root/#{d}.done
    EOC
    creates "/root/#{d}.done"
  end
end
