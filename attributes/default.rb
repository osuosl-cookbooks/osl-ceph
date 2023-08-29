default['osl-ceph']['config'] = {}
default['osl-ceph']['data_bag_item'] = nil
default['osl-ceph']['nrpe']['check_ceph_df'] = {
  warning: 80,
  critical: 90,
}
default['osl-ceph']['nrpe']['check_ceph_osd']['critical'] = 1
