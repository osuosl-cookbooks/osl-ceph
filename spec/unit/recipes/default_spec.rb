require_relative '../../spec_helper'

describe 'osl-ceph::default' do
  ALL_PLATFORMS.each do |p|
    context "on #{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { is_expected.to install_osl_ceph_install 'default' }
      it { is_expected.to_not create_osl_ceph_config 'default' }

      context 'cluster defined' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.normal['osl-ceph']['config'] = {
              fsid: '92d28eec-abc3-42c2-8332-8b0d8232ca9f',
              mon_initial_members: %w(node1),
              mon_host: %w(192.168.1.100),
              public_network: %w(192.168.1.0/24),
              cluster_network: %w(192.168.1.0/24),
              client_options: ['foo bar = foo'],
            }
          end.converge(described_recipe)
        end

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
  end
end
