3.times do |i|
  execute "create loop#{i}" do
    command <<-EOF
      dd if=/dev/zero of=/root/loop#{i} bs=1M count=3072
      losetup /dev/loop#{i} /root/loop#{i}
    EOF
    creates "/root/loop#{i}"
  end
end

execute 'hostnamectl set-hostname node1.example.org' do
  not_if 'hostname -f | grep node1.example.org'
end
