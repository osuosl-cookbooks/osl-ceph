include_recipe 'ceph_test::radosgw'

# The admin RGW user is created manually in production; create it here with
# the keys from the test data bag so create-s3-bucket can authenticate.
execute 'create admin rgw user' do
  command 'radosgw-admin user create --uid=admin --display-name="OSL Admin" ' \
          '--access-key TESTACCESSKEY --secret-key TESTSECRETKEY'
  not_if 'radosgw-admin user info --uid=admin'
end

# Point s3cmd at the local RGW. The endpoint must match rgw_dns_name (the
# node fqdn) or RGW misparses path-style requests as virtual-host style.
node.override['osl-ceph']['s3']['host_base'] = "#{node['fqdn']}:8080"
node.override['osl-ceph']['s3']['host_bucket'] = "#{node['fqdn']}:8080"
node.override['osl-ceph']['s3']['use_https'] = false

include_recipe 'osl-ceph::s3_admin'
