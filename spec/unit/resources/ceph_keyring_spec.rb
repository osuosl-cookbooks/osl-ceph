require_relative '../../spec_helper'

describe 'ceph_test::spec_ceph_keyring' do
  ALL_PLATFORMS.each do |p|
    context "on #{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p.merge(step_into: 'osl_ceph_keyring')).converge(described_recipe)
      end

      it do
        is_expected.to create_osl_ceph_keyring('test').with(key: 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==')
      end
      it do
        is_expected.to create_osl_ceph_keyring('test2')
          .with(
            key: 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==',
            key_name: 'test2-name',
            key_filename: 'test2-filename',
            owner: 'nobody',
            group: 'nobody',
            ceph_dir: '/tmp'
          )
      end
      it do
        is_expected.to delete_osl_ceph_keyring('delete')
      end
      it do
        is_expected.to create_file('/etc/ceph/ceph.client.test.keyring')
          .with(
            content: "[client.test]\n\tkey = AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==\n",
            sensitive: true,
            owner: 'ceph',
            group: 'ceph',
            mode: '0640'
          )
      end
      it do
        is_expected.to create_file('/tmp/test2-filename')
          .with(
            content: "[test2-name]\n\tkey = AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==\n",
            sensitive: true,
            owner: 'nobody',
            group: 'nobody',
            mode: '0640'
          )
      end
      it do
        is_expected.to delete_file('/etc/ceph/ceph.client.delete.keyring')
      end
    end
  end
end
