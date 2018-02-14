require 'chef/provisioning'

machine 'node3' do
  machine_options bootstrap_options: {
    image_ref: ENV['NODE_OS'],
    flavor_ref: ENV['FLAVOR'],
    key_name: ENV['OS_SSH_KEYPAIR'],
    nics: [{ net_id: ENV['OS_NETWORK_UUID'] }]
  },
                  ssh_username: 'centos',
                  ssh_options: {
                    key_data: nil
                  },
                  convergence_options: {
                    chef_version: '12.18.31'
                  }

  ohai_hints 'openstack' => '{}'
  attribute %w(ceph_test openstack_auth_url), "#{ENV['OS_AUTH_URL']}/tokens"
  attribute %w(ceph_test openstack_username), ENV['OS_USERNAME']
  attribute %w(ceph_test openstack_api_key), ENV['OS_PASSWORD']
  attribute %w(ceph_test openstack_tenant), ENV['OS_TENANT_NAME']
  role 'ceph'
  role 'ceph_mon'
  role 'ceph_mgr'
  role 'ceph_osd'
  file('/etc/chef/encrypted_data_bag_secret', File.dirname(__FILE__) + '/../encrypted_data_bag_secret')
  converge true
end
