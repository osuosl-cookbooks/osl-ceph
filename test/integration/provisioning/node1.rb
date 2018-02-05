require 'chef/provisioning'

node_os = ENV['NODE_OS'] || 'bento/centos-7.4'
flavor_ref = ENV['FLAVOR'] || 4 # m1.large

unless ENV['CHEF_DRIVER'] == 'fog:OpenStack'
  require 'chef/provisioning/vagrant_driver'
  vagrant_box node_os
  with_driver "vagrant:#{File.dirname(__FILE__)}/../../../vms"
end

machine 'node1' do
  machine_options vagrant_options: {
    'vm.box' => node_os
  },
                  bootstrap_options: {
                    image_ref: node_os,
                    flavor_ref: flavor_ref,
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
  add_machine_options vagrant_config: <<-EOF
config.vm.network "private_network", ip: "192.168.60.10"
config.vm.provider "virtualbox" do |v|
  v.memory = 4096
  v.cpus = 2
end
EOF
  attribute %w(ceph_test openstack_auth_url), "#{ENV['OS_AUTH_URL']}/tokens"
  attribute %w(ceph_test openstack_username), ENV['OS_USERNAME']
  attribute %w(ceph_test openstack_api_key), ENV['OS_PASSWORD']
  attribute %w(ceph_test openstack_tenant), ENV['OS_TENANT_NAME']
  role 'ceph'
  role 'ceph_mon'
  role 'ceph_mgr'
  role 'ceph_osd'
  file('/etc/chef/encrypted_data_bag_secret',
       File.dirname(__FILE__) +
       '/../encrypted_data_bag_secret')
  converge true
end
