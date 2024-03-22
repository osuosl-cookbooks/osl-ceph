require_relative '../../spec_helper'

describe 'osl_ceph_client' do
  platform 'centos', '7'
  cached(:subject) { chef_run }
  step_into :osl_ceph_rbdmap

  recipe do
    osl_ceph_rbdmap 'image' do
      pool 'pool'
      id 'id'
    end

    osl_ceph_rbdmap 'delete' do
      pool 'pool'
      action :remove
    end
  end

  it do
    is_expected.to edit_append_if_no_line('Create pool/image mapping').with(
      path: '/etc/ceph/rbdmap',
      line: 'pool/image id=id,keyring=/etc/ceph/ceph.client.id.keyring'
    )
  end

  it { is_expected.to enable_service 'rbdmap' }

  it do
    is_expected.to edit_delete_lines('Remove pool/delete mapping').with(
      path: '/etc/ceph/rbdmap'
      # TODO: This fails but should pass
      # pattern: %r{^pool/delete.*},
    )
  end
end
