require 'chefspec'
require 'chefspec/berkshelf'

# rubocop:disable MutableConstant
CENTOS_7 = {
  platform: 'centos',
  version: '7.4.1708',
}

ALL_PLATFORMS = [
  CENTOS_7,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
end

shared_context 'chef_server' do |platform, arch|
  cached(:chef_run) do
    mon_node = stub_node('mon', platform) do |node|
      node.automatic['fqdn'] = 'ceph-mon.example.org'
      node.automatic['roles'] = 'search-ceph-mon'
    end
    ChefSpec::ServerRunner.new(platform) do |node, server|
      server.create_node(mon_node)
      node.automatic['kernel']['machine'] = arch.nil? ? 'x86_64' : arch
      server.create_data_bag(
        'ceph',
        'nagios' => {
          'nagios_token' => {
            'x86' => 'x86_key',
            'ppc64' => 'ppc64_key',
          },
        }
      )
    end.converge(described_recipe)
  end
  include_context 'common_stubs'
end

shared_context 'common_stubs' do
  before do
    stub_command('test -s /etc/yum.repos.d/ceph.repo')
    stub_command('test -s /lib/lsb/init-functions')
    stub_command('getenforce | grep \'Permissive|Disabled\'')
    stub_command('test -f /etc/ceph')
    stub_command('test -s /etc/ceph/ceph.mon.keyring')
    stub_command('test -s /etc/ceph/ceph.client.admin.keyring')
    stub_command('grep \'admin\' /etc/ceph/ceph.mon.keyring')
    stub_command('test -d /var/lib/ceph/mds/ceph-Fauxhai')
    stub_command('test -s /var/lib/ceph/mon/ceph-Fauxhai/keyring')
    stub_command('test -f /var/lib/ceph/mon/ceph-Fauxhai/done')
    stub_command('test -d /var/lib/ceph/mgr/ceph-Fauxhai')
    stub_command('test -s /var/lib/ceph/mgr/ceph-Fauxhai/keyring')
    stub_command('test -d /etc/ceph/scripts')
    stub_command('test -f /etc/ceph/scripts/ceph_journal.sh')
    stub_command('test -s /var/lib/ceph/bootstrap-osd/ceph.keyring')
  end
end
