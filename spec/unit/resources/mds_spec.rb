require_relative '../../spec_helper'

describe 'osl_ceph_mds' do
  platform 'almalinux', '8'
  cached(:subject) { chef_run }
  step_into :osl_ceph_mds

  before do
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with('/etc/ceph/ceph.conf').and_return('fsid = c7f0a62c-909c-4089-bce9-83d6b2bacf88')
  end

  recipe do
    osl_ceph_mds 'default'
  end

  it do
    is_expected.to create_directory('/var/lib/ceph/mds/ceph-Fauxhai').with(
      owner: 'ceph',
      group: 'ceph',
      recursive: true
    )
  end

  it do
    is_expected.to run_execute('create mds keyring').with(
      user: 'ceph',
      group: 'ceph',
      command: "ceph-authtool --create-keyring /var/lib/ceph/mds/ceph-Fauxhai/keyring --gen-key -n mds.Fauxhai\nceph auth add mds.Fauxhai   osd \"allow rwx\" mds \"allow\" mon \"allow profile mds\"   -i /var/lib/ceph/mds/ceph-Fauxhai/keyring\n",
      sensitive: true,
      creates: '/var/lib/ceph/mds/ceph-Fauxhai/keyring'
    )
  end

  it { is_expected.to enable_service('ceph-mds@Fauxhai.service') }
  it { is_expected.to start_service('ceph-mds@Fauxhai.service') }
end
