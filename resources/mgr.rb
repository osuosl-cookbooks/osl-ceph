resource_name :osl_ceph_mon
provides :osl_ceph_mon
default_action :start
unified_mode true

action :start do
  directory "/var/lib/ceph/mgr/ceph-#{node['hostname']}" do
    owner 'ceph'
    group 'ceph'
    recursive true
  end

  file "/var/lib/ceph/mgr/ceph-#{node['hostname']}/keyring" do
    owner 'ceph'
    group 'ceph'
    content ceph_mgr_auth
    sensitive true
    action :create_if_missing
  end

  link "/etc/ceph/ceph.mgr.#{node['hostname']}.keyring" do
    to "/var/lib/ceph/mgr/ceph-#{node['hostname']}/keyring"
  end

  service "ceph-mgr@#{node['hostname']}.service" do
    action [:enable, :start]
  end
end

action :restart do
  service "ceph-mgr@#{node['hostname']}.service" do
    action :restart
  end
end
