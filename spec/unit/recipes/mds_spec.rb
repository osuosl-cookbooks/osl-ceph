require_relative '../../spec_helper'

describe 'osl-ceph::mds' do
  ALL_PLATFORMS.each do |p|
    context "on #{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { is_expected.to include_recipe 'osl-ceph' }
      it { is_expected.to install_osl_ceph_install('mds').with(mds: true) }
      it { is_expected.to start_osl_ceph_mds 'mds' }
    end
  end
end
