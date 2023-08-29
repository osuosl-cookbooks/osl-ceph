case node['hostname']
when 'node1'
  ip = '10.1.2.10'
when 'node2'
  ip = '10.1.2.11'
when 'node3'
  ip = '10.1.2.12'
when 'cephfs-client'
  ip = '10.1.2.20'
end

secondary_interface = node['network']['default_interface'] == 'eth0' ? 'eth1' : 'ens3'

osl_ifconfig ip do
  onboot 'yes'
  mask '255.255.255.0'
  network '10.1.2.0'
  device secondary_interface
end
