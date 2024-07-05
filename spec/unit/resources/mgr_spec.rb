require_relative '../../spec_helper'

describe 'osl_ceph_mgr' do
  platform 'almalinux', '8'
  cached(:subject) { chef_run }
  step_into :osl_ceph_mgr

  before do
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with('/etc/ceph/ceph.conf').and_return('fsid = c7f0a62c-909c-4089-bce9-83d6b2bacf88')
    allow_any_instance_of(OslCeph::Cookbook::Helpers).to receive(:ceph_mgr_auth).and_return('mgr key')
  end

  recipe do
    osl_ceph_mgr 'default'
  end

  it do
    is_expected.to create_directory('/var/lib/ceph/mgr/ceph-Fauxhai').with(
      owner: 'ceph',
      group: 'ceph',
      recursive: true
    )
  end

  it do
    is_expected.to create_if_missing_file('/var/lib/ceph/mgr/ceph-Fauxhai/keyring').with(
      owner: 'ceph',
      group: 'ceph',
      content: 'mgr key',
      sensitive: true
    )
  end

  it do
    expect(chef_run.link('/etc/ceph/ceph.mgr.Fauxhai.keyring')).to \
      link_to('/var/lib/ceph/mgr/ceph-Fauxhai/keyring')
  end

  it { is_expected.to enable_service('ceph-mgr@Fauxhai.service') }
  it { is_expected.to start_service('ceph-mgr@Fauxhai.service') }
end
