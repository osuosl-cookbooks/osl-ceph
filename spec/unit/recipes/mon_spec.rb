require_relative '../../spec_helper'

describe 'osl-ceph::mon' do
  ALL_PLATFORMS.each do |p|
    context "on #{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { is_expected.to include_recipe 'osl-ceph' }
      it { is_expected.to install_osl_ceph_install('mon').with(mon: true) }
      it { is_expected.to_not start_osl_ceph_mon 'mon' }

      context 'cluster defined' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.normal['osl-ceph']['data_bag_item'] = 'cluster'
          end.converge(described_recipe)
        end

        before do
          stub_data_bag_item('ceph', 'cluster').and_return(
            mon_key: 'mon_key',
            admin_key: 'admin_key',
            bootstrap_key: 'bootstrap_key'
          )
        end

        it do
          is_expected.to start_osl_ceph_mon('mon').with(
            mon_key: 'mon_key',
            admin_key: 'admin_key',
            bootstrap_key: 'bootstrap_key',
            generate_monmap: false
          )
        end
      end
    end
  end
end
