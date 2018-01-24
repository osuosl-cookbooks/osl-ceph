3.times do |i|
  execute "create loop#{i}" do
    command <<-EOF
      dd if=/dev/zero of=/root/loop#{i} bs=1M count=3072
      losetup /dev/loop#{i} /root/loop#{i}
    EOF
    #  parted /dev/loop#{i} mklabel gpt
    #  parted /dev/loop#{i} mkpart primary xfs 1 100%
    creates "/root/loop#{i}"
  end
end

execute 'hostnamectl set-hostname node1.example.org' do
  not_if 'hostname -f | grep node1.example.org'
end

package 'dnsmasq'

template '/etc/dnsmasq.d/ceph' do
  source 'dnsmasq.erb'
  notifies :restart, 'service[dnsmasq]'
end

service 'dnsmasq' do
  action [:start, :enable]
end

node.default['resolver']['domain'] = 'example.org'
node.default['resolver']['search'] = 'example.org'
node.default['resolver']['nameservers'] = %w(127.0.0.1)

include_recipe 'resolver'
