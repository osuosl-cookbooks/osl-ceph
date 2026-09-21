provides :osl_ceph_exporter
default_action :start
unified_mode true

action :start do
  # The RPM's ExecStart passes --id %i, which a plain unit expands to an empty
  # client name; the daemon then aborts fetching config from the mons.
  osl_systemd_unit_drop_in 'no-mon-config' do
    unit_name 'ceph-exporter.service'
    content <<~EOC
      [Service]
      ExecStart=
      ExecStart=/usr/bin/ceph-exporter -f --no-mon-config --setuser ceph --setgroup ceph
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
