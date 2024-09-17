require_relative '../../spec_helper'

describe 'osl-ceph::osd' do
  ALL_PLATFORMS.each do |p|
    context "on #{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { is_expected.to include_recipe 'osl-ceph' }
      it { is_expected.to install_osl_ceph_install('osd').with(osd: true) }
      it { is_expected.to enable_service 'ceph-osd.target' }
      it { is_expected.to start_service 'ceph-osd.target' }
      it { is_expected.to_not create_osl_ceph_keyring 'bootstrap-osd' }

      context 'bootstrap-osd set' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.normal['osl-ceph']['data_bag_item'] = 'cluster'
          end.converge(described_recipe)
        end

        before do
          stub_data_bag_item('ceph', 'cluster').and_return(
            bootstrap_key: 'bootstrap_key'
          )
        end

        it { is_expected.to create_osl_ceph_keyring('bootstrap-osd').with(key: 'bootstrap_key') }
      end
    end
  end
end
