default['osl-ceph']['nrpe']['check_ceph_df'] = {
  warning: 80,
  critical: 90,
}
default['osl-ceph']['nrpe']['check_ceph_osd']['critical'] = 1
default['osl-ceph']['create-filesystem-osd'] = false
default['osl-ceph']['filesystem-osd-ids'] = %w(0 1 2)
