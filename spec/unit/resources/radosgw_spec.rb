require_relative '../../spec_helper'

describe 'ceph_test::radosgw' do
  ALL_PLATFORMS.each do |p|
    context "on #{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p.merge(step_into: 'osl_ceph_radosgw')).converge(described_recipe)
      end

      it { is_expected.to accept_osl_firewall_port('http').with(ports: %w(8080)) }

      it do
        is_expected.to create_directory('/var/lib/ceph/radosgw/ceph-Fauxhai').with(
          owner: 'ceph',
          group: 'ceph',
          recursive: true
        )
      end

      it do
        is_expected.to run_execute('create radosgw keyring').with(
          user: 'ceph',
          group: 'ceph',
          command: "ceph-authtool --create-keyring /var/lib/ceph/radosgw/ceph-Fauxhai/keyring --gen-key -n client.rgw.Fauxhai\nceph auth add client.rgw.Fauxhai osd \"allow rwx\" mon \"allow rw\" -i /var/lib/ceph/radosgw/ceph-Fauxhai/keyring\n",
          sensitive: true,
          creates: '/var/lib/ceph/radosgw/ceph-Fauxhai/keyring'
        )
      end

      it do
        expect(chef_run.link('/etc/ceph/ceph.rgw.Fauxhai.keyring')).to link_to('/var/lib/ceph/radosgw/ceph-Fauxhai/keyring')
      end

      it { is_expected.to enable_service('ceph-radosgw@rgw.Fauxhai.service') }
      it { is_expected.to start_service('ceph-radosgw@rgw.Fauxhai.service') }
    end
  end
end
