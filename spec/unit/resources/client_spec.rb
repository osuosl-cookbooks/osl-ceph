require_relative '../../spec_helper'

describe 'osl_ceph_client' do
  platform 'almalinux', '8'
  cached(:subject) { chef_run }
  step_into :osl_ceph_client

  before do
    allow_any_instance_of(OslCeph::Cookbook::Helpers).to receive(:ceph_auth_exists?).and_return(false)
    allow_any_instance_of(OslCeph::Cookbook::Helpers).to receive(:ceph_create_entity)
  end

  recipe do
    osl_ceph_client 'test' do
      key 'foo'
    end
  end

  it do
    is_expected.to create_file('/etc/ceph/ceph.client.test.Fauxhai.keyring').with(
      content: "[client.test.Fauxhai]\n\tkey = foo\n",
      owner: 'ceph',
      group: 'ceph',
      mode: '0640',
      sensitive: true
    )
  end
end
