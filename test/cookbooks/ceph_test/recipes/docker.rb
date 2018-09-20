node.override['osl-docker']['service'] = { misc_opts: '--live-restore' }

include_recipe 'osl-docker'

docker_image 'osuosl/ceph' do
  action :pull
end

# Run a container-based ceph server for testing
docker_container 'ceph' do
  repo 'osuosl/ceph'
  network_mode 'host'
  volumes ['/etc/ceph-docker1:/etc/ceph']
  env [
    "MON_IP=#{node['ipaddress']}",
    'CEPH_PUBLIC_NETWORK=10.1.100.0/22',
    'RGW_CIVETWEB_PORT=8000',
    'RESTAPI_PORT=8001',
  ]
  action :run
end

# We need to wait for the cluster to be in a healthy state before doing actions with it
ruby_block 'wait for ceph' do
  block do
    require 'English'
    true until ::File.exist?('/etc/ceph-docker1/ceph.client.admin.keyring')
    system('docker logs ceph 2>1 | grep -q HEALTH_OK')
    until $CHILD_STATUS.exitstatus == 0
      sleep 1
      system('docker logs ceph 2>1 | grep -q HEALTH_OK')
    end
  end
end

directory '/etc/ceph'

link '/etc/ceph/ceph.client.admin.keyring' do
  to '/etc/ceph-docker1/ceph.client.admin.keyring'
end

execute 'cp -rf /etc/ceph-docker1/ceph.conf /etc/ceph/ceph.conf'

# Create a temp file inside of the container that will be used for importing the key
file '/etc/ceph-docker1/client.nagios' do
  content "[client.nagios]\n\tkey = AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==\n"
end

# Importing a the nagios auth key
execute 'add client.nagios keyring' do
  command <<-EOH
    docker container exec ceph \
      ceph auth -i /etc/ceph/client.nagios add client.nagios mon 'allow r' > \
      /etc/ceph-docker1/ceph.client.nagios.keyring
  EOH
  creates '/etc/ceph-docker1/ceph.client.nagios.keyring'
end

# Add tags so that it will be searchable
tag('ceph-mon-x86')
tag('ceph-mon-ppc64')
