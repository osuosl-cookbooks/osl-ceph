require_relative '../../spec_helper'

describe 'osl-ceph::osd' do
  platform 'centos', '7'
  cached(:subject) { chef_run }

  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end

  it { is_expected.to include_recipe 'osl-ceph' }
  it { is_expected.to install_osl_ceph_install('osd').with(osd: true) }
  it { is_expected.to enable_service 'ceph-osd.target' }
  it { is_expected.to start_service 'ceph-osd.target' }
end
