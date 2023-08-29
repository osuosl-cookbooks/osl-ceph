resource_name :osl_cephfs
provides :osl_cephfs
unified_mode true
default_action :mount

property :key, String, required: [:enable, :mount], sensitive: true
property :client_name, String, default: 'admin'
property :subdir, String, default: '/'
property :options, String

action :enable do
  file "ceph.client secret for #{new_resource.name}" do
    path "/etc/ceph/ceph.client.#{new_resource.client_name}.secret"
    content "#{new_resource.key}\n"
    sensitive true
    owner 'ceph'
    group 'ceph'
    mode '0600'
  end

  directory new_resource.name do
    recursive true
  end

  # TODO: Workaround https://github.com/chef/chef/issues/10764
  subdir = new_resource.subdir.match?('^/$') ? '//' : new_resource.subdir

  mons = ceph_mon_addresses.sort.join(',') + ':' + subdir

  mount new_resource.name do
    fstype 'ceph'
    device mons
    options [ceph_mount_opts, new_resource.options].join(',')
    dump 0
    pass 0
    action :enable
  end
end

action :mount do
  action_enable

  # TODO: Workaround https://github.com/chef/chef/issues/10764
  subdir = new_resource.subdir.match?('^/$') ? '//' : new_resource.subdir

  mons = ceph_mon_addresses.sort.join(',') + ':' + subdir

  mount new_resource.name do
    fstype 'ceph'
    device mons
    options [ceph_mount_opts, new_resource.options].join(',')
    dump 0
    pass 0
    action :mount
  end
end

action :umount do
  file "ceph.client secret for #{new_resource.name}" do
    path "/etc/ceph/ceph.client.#{new_resource.client_name}.secret"
    sensitive true
    action :delete
  end

  mons = ceph_mon_addresses.sort.join(',') + ':' + new_resource.subdir

  mount new_resource.name do
    fstype 'ceph'
    device mons
    options [ceph_mount_opts, new_resource.options].join(',')
    dump 0
    pass 0
    action [:umount, :disable]
  end
end
