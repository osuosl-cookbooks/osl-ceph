default['osl-ceph']['config'] = {}
default['osl-ceph']['data_bag_item'] = nil
default['osl-ceph']['nrpe']['check_ceph_osd']['critical'] = 1
default['osl-ceph']['s3']['host_base'] = 's3.osuosl.org'
# Defaults to %(bucket)s.<host_base> when nil
default['osl-ceph']['s3']['host_bucket'] = nil
default['osl-ceph']['s3']['use_https'] = true
