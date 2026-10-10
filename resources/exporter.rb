provides :osl_ceph_exporter
default_action :start
unified_mode true

action :start do
  # The RPM's --id %i expands to an empty client name in a plain unit; as client.admin it would
  # also take ceph-client.admin.asok from root's ceph CLI, hence its own --admin-socket.
  osl_systemd_unit_drop_in 'no-mon-config' do
    unit_name 'ceph-exporter.service'
    content <<~EOC
      [Service]
      ExecStart=
      ExecStart=/usr/bin/ceph-exporter -f --no-mon-config --admin-socket /var/run/ceph/ceph-exporter.asok --setuser ceph --setgroup ceph
    EOC
    notifies :restart, 'service[ceph-exporter.service]', :delayed
  end

  service 'ceph-exporter.service' do
    action [:enable, :start]
  end
end

action :restart do
  service 'ceph-exporter.service' do
    action :restart
  end
end
