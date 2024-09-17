require_relative '../../spec_helper'

describe 'osl-ceph::mgr' do
  ALL_PLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { is_expected.to include_recipe 'osl-ceph' }
      it { is_expected.to install_osl_ceph_install('mgr').with(mgr: true) }
      it { is_expected.to start_osl_ceph_mgr 'mgr' }
    end
  end
end
