resource_name :osl_ceph_mds
provides :osl_ceph_mds
default_action :start
unified_mode true

action :start do
  mds_keyring = "/var/lib/ceph/mds/ceph-#{node['hostname']}/keyring"

  directory "/var/lib/ceph/mds/ceph-#{node['hostname']}" do
    owner 'ceph'
    group 'ceph'
    recursive true
  end

  execute 'create mds keyring' do
    user 'ceph'
    group 'ceph'
    command <<~EOC
      ceph-authtool --create-keyring #{mds_keyring} --gen-key -n mds.#{node['hostname']}
      ceph auth add mds.#{node['hostname']} \
        osd "allow rwx" mds "allow" mon "allow profile mds" \
        -i #{mds_keyring}
    EOC
    sensitive true
    creates mds_keyring
  end

  service "ceph-mds@#{node['hostname']}.service" do
    action [:enable, :start]
  end
end
