resource_name :osl_ceph_radosgw
provides :osl_ceph_radosgw
default_action :start
unified_mode true

action :start do
  osl_firewall_port 'http' do
    ports %w(8080)
  end

  radosgw_keyring = "/var/lib/ceph/radosgw/ceph-#{node['hostname']}/keyring"

  directory "/var/lib/ceph/radosgw/ceph-#{node['hostname']}" do
    owner 'ceph'
    group 'ceph'
    recursive true
  end

  execute 'create radosgw keyring' do
    user 'ceph'
    group 'ceph'
    command <<~EOC
      ceph-authtool --create-keyring #{radosgw_keyring} --gen-key -n client.rgw.#{node['hostname']}
      ceph auth add client.rgw.#{node['hostname']} osd "allow rwx" mon "allow rw" -i #{radosgw_keyring}
    EOC
    sensitive true
    creates radosgw_keyring
  end

  link "/etc/ceph/ceph.rgw.#{node['hostname']}.keyring" do
    to "/var/lib/ceph/radosgw/ceph-#{node['hostname']}/keyring"
  end

  service "ceph-radosgw@rgw.#{node['hostname']}.service" do
    action [:enable, :start]
  end
end

action :restart do
  service "ceph-radosgw@rgw.#{node['hostname']}.service" do
    action :restart
  end
end
