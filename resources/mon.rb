resource_name :osl_ceph_mon
provides :osl_ceph_mon
default_action :start
unified_mode true

property :admin_key, String, sensitive: true
property :bootstrap_key, String, sensitive: true
property :generate_monmap, [true, false], default: true
property :ipaddress, String, default: lazy { node['ipaddress'] }
property :mon_key, String, sensitive: true

action :start do
  mon_keyring = '/tmp/ceph.mon.keyring'
  admin_keyring = '/etc/ceph/ceph.client.admin.keyring'
  bootstrap_keyring = '/var/lib/ceph/bootstrap-osd/ceph.keyring'
  mon_key = new_resource.mon_key ? "--add-key=#{new_resource.mon_key}" : '--gen-key'
  admin_key = new_resource.admin_key ? "--add-key=#{new_resource.admin_key}" : '--gen-key'
  bootstrap_key = new_resource.bootstrap_key ? "--add-key=#{new_resource.bootstrap_key}" : '--gen-key'

  execute 'create mon keyring' do
    user 'ceph'
    group 'ceph'
    command "ceph-authtool --create-keyring #{mon_keyring} #{mon_key} -n mon. --cap mon 'allow *'"
    sensitive true
    creates "/var/lib/ceph/mon/ceph-#{node['hostname']}/done"
  end

  execute 'create admin keyring' do
    command <<~EOC
      ceph-authtool --create-keyring #{admin_keyring} #{admin_key} -n client.admin \
        --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
    EOC
    sensitive true
    creates "/var/lib/ceph/mon/ceph-#{node['hostname']}/done"
  end

  execute 'create bootstrap-osd keyring' do
    command <<~EOC
      ceph-authtool --create-keyring #{bootstrap_keyring} \
        #{bootstrap_key} -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'
    EOC
    sensitive true
    creates "/var/lib/ceph/mon/ceph-#{node['hostname']}/done"
  end

  execute 'import admin key' do
    command "ceph-authtool #{mon_keyring} --import-keyring #{admin_keyring}"
    sensitive true
    creates "/var/lib/ceph/mon/ceph-#{node['hostname']}/done"
  end

  execute 'import boostrap-osd key' do
    command "ceph-authtool #{mon_keyring} --import-keyring #{bootstrap_keyring}"
    sensitive true
    creates "/var/lib/ceph/mon/ceph-#{node['hostname']}/done"
  end

  directory "/var/lib/ceph/mon/ceph-#{node['hostname']}" do
    owner 'ceph'
    group 'ceph'
  end

  execute 'generate monitor map' do
    command <<~EOC
      monmaptool --create --add \
        #{node['hostname']} #{new_resource.ipaddress} --fsid #{ceph_fsid} /etc/ceph/monmap
    EOC
    sensitive true
    creates '/etc/ceph/monmap'
    only_if { new_resource.generate_monmap }
  end

  file '/etc/ceph/monmap' do
    owner 'ceph'
    group 'ceph'
    only_if { new_resource.generate_monmap }
  end

  [
    admin_keyring,
    bootstrap_keyring,
  ].each do |f|
    file f do
      owner 'ceph'
      group 'ceph'
    end
  end

  execute 'populate monitor map' do
    user 'ceph'
    group 'ceph'
    if new_resource.generate_monmap
      command <<~EOC
        ceph-mon --mkfs -i #{node['hostname']} --monmap /etc/ceph/monmap --keyring #{mon_keyring}
        touch /var/lib/ceph/mon/ceph-#{node['hostname']}/done
      EOC
    else
      command <<~EOC
        ceph-mon --mkfs -i #{node['hostname']} --keyring #{mon_keyring}
        touch /var/lib/ceph/mon/ceph-#{node['hostname']}/done
      EOC
    end
    sensitive true
    creates "/var/lib/ceph/mon/ceph-#{node['hostname']}/done"
  end

  service "ceph-mon@#{node['hostname']}.service" do
    action [:enable, :start]
  end

  file mon_keyring do
    sensitive true
    action :delete
  end
end
