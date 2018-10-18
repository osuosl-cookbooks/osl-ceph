require 'chef/provisioning'

machine 'node1' do
  machine_options bootstrap_options: {
    image_ref: ENV['NODE_OS'],
    flavor_ref: ENV['FLAVOR'],
    key_name: ENV['OS_SSH_KEYPAIR'],
    nics: [{ net_id: ENV['OS_NETWORK_UUID'] }],
  },
                  ssh_username: 'centos',
                  ssh_options: {
                    key_data: nil,
                  },
                  convergence_options: {
                    chef_version: '13.8.5',
                  }

  role 'ceph'
  role 'ceph_mon'
  role 'ceph_mgr'
  role 'ceph_osd'
  file('/etc/chef/encrypted_data_bag_secret', File.dirname(__FILE__) + '/../encrypted_data_bag_secret')
  converge true
end
