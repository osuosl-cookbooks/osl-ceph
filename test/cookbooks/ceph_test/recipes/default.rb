# Create wal and blk devices
0.upto(1) do |i|
  execute "create ssd#{i}" do
    command <<-EOF
      dd if=/dev/zero of=/root/loop#{i} bs=1M count=4096
      losetup /dev/loop#{i} /root/loop#{i}
      parted --script /dev/loop#{i} \
        mklabel gpt \
        mkpart primary 1MiB 512MiB \
        mkpart primary 512MiB 1Gib \
        mkpart primary 1Gib 1.5Gib \
        mkpart primary 1.5Gib 2Gib
      kpartx -a /dev/loop#{i}
    EOF
    creates "/dev/mapper/loop#{i}p1"
  end
end

# Create OSD devices
2.upto(4) do |i|
  execute "create osd#{i}" do
    command <<-EOF
      dd if=/dev/zero of=/root/loop#{i} bs=1M count=4096
      losetup /dev/loop#{i} /root/loop#{i}
      parted --script /dev/loop#{i} \
        mklabel gpt \
        mkpart primary 1 100%
      kpartx -a /dev/loop#{i}
    EOF
    creates "/dev/mapper/loop#{i}p1"
  end
end

execute 'hostnamectl set-hostname node1.example.org' do
  not_if 'hostname -f | grep node1.example.org'
end
