require_relative '../../spec_helper'

describe 'ceph_test::ceph_keyring' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(
          p.dup.merge(step_into: %w(ceph_keyring))
        ).converge(described_recipe)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to create_ceph_keyring('test').with(key: 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==')
      end
      it do
        expect(chef_run).to create_ceph_keyring('test2')
          .with(
            key: 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==',
            key_name: 'test2-name',
            key_filename: 'test2-filename',
            owner: 'nobody',
            group: 'nobody',
            chef_dir: '/tmp'
          )
      end
      it do
        expect(chef_run).to delete_ceph_keyring('delete')
      end
      it do
        expect(chef_run).to create_file('/etc/ceph/ceph.client.test.keyring')
          .with(
            content: "[client.test]\n\tkey = AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==\n",
            sensitive: true,
            owner: 'ceph',
            group: 'ceph',
            mode: '0600'
          )
      end
      it do
        expect(chef_run).to create_file('/tmp/test2-filename')
          .with(
            content: "[test2-name]\n\tkey = AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==\n",
            sensitive: true,
            owner: 'nobody',
            group: 'nobody',
            mode: '0600'
          )
      end
      it do
        expect(chef_run).to delete_file('/etc/ceph/ceph.client.delete.keyring')
      end
    end
  end
end
