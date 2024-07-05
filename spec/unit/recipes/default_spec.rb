require_relative '../../spec_helper'

describe 'osl-ceph::default' do
  platform 'almalinux', '8'
  cached(:subject) { chef_run }

  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end

  it { is_expected.to install_osl_ceph_install 'default' }
  it { is_expected.to_not create_osl_ceph_config 'default' }

  context 'cluster defined' do
    cached(:subject) { chef_run }

    override_attributes['osl-ceph']['config'] = {
      fsid: '92d28eec-abc3-42c2-8332-8b0d8232ca9f',
      mon_initial_members: %w(node1),
      mon_host: %w(192.168.1.100),
      public_network: %w(192.168.1.0/24),
      cluster_network: %w(192.168.1.0/24),
      client_options: ['foo bar = foo'],
    }

    it do
      is_expected.to create_osl_ceph_config('default').with(
        fsid: '92d28eec-abc3-42c2-8332-8b0d8232ca9f',
        mon_initial_members: %w(node1),
        mon_host: %w(192.168.1.100),
        public_network: %w(192.168.1.0/24),
        cluster_network: %w(192.168.1.0/24),
        client_options: ['foo bar = foo']
      )
    end
  end
end
