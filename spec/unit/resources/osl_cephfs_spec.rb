require_relative '../../spec_helper'

describe 'ceph_test::mds' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        mon_node = stub_node('mon', p) do |node|
          node.automatic['fqdn'] = 'ceph-mon.example.org'
          node.automatic['roles'] = 'search-ceph-mon'
          node.automatic['tags'] = %w(ceph-admin ceph-mon ceph-mds)
        end
        ChefSpec::ServerRunner.new(p.dup.merge(step_into: %w(osl_cephfs))) do |node, server|
          node.automatic['ceph']['mon']['role'] = 'search-ceph-mon'
          node.automatic['ceph']['network']['public']['cidr'] = %w(10.0.0.0/24)
          node.automatic['ceph']['network']['cluster']['cidr'] = %w(10.0.0.0/24)
          server.create_node(mon_node)
          server.create_data_bag(
            'ceph',
            'nagios' => {
              'nagios_token' => {
                'x86' => 'x86_key',
                'ppc64' => 'ppc64_key',
              },
            }
          )
        end.converge(described_recipe)
      end
      include_context 'common_stubs'
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to mount_osl_cephfs('/mnt/ceph')
          .with(
            key: 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==',
            client_name: 'cephfs'
          )
      end
      it do
        expect(chef_run).to create_file('ceph.client secret for /mnt/ceph')
          .with(
            path: '/etc/ceph/ceph.client.cephfs.secret',
            content: "AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==\n",
            sensitive: true,
            owner: 'ceph',
            group: 'ceph',
            mode: '0600'
          )
      end
      it do
        expect(chef_run).to create_directory('/mnt/ceph').with(recursive: true)
      end
      it do
        expect(chef_run).to mount_mount('/mnt/ceph')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:6789://',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
      it do
        expect(chef_run).to enable_mount('/mnt/ceph')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:6789://',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
      it do
        expect(chef_run).to mount_osl_cephfs('/mnt/foo')
          .with(
            key: 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==',
            subdir: '/foo',
            client_name: 'cephfs'
          )
      end
      it do
        expect(chef_run).to create_file('ceph.client secret for /mnt/foo')
          .with(
            path: '/etc/ceph/ceph.client.cephfs.secret',
            content: "AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==\n",
            sensitive: true,
            owner: 'ceph',
            group: 'ceph',
            mode: '0600'
          )
      end
      it do
        expect(chef_run).to create_directory('/mnt/foo').with(recursive: true)
      end
      it do
        expect(chef_run).to mount_mount('/mnt/foo')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:6789:/foo',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
      it do
        expect(chef_run).to enable_mount('/mnt/foo')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:6789:/foo',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
      it do
        expect(chef_run).to mount_osl_cephfs('/mnt/bar')
          .with(
            key: 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==',
            subdir: '/bar',
            client_name: 'cephfs'
          )
      end
      it do
        expect(chef_run).to create_file('ceph.client secret for /mnt/bar')
          .with(
            path: '/etc/ceph/ceph.client.cephfs.secret',
            content: "AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==\n",
            sensitive: true,
            owner: 'ceph',
            group: 'ceph',
            mode: '0600'
          )
      end
      it do
        expect(chef_run).to create_directory('/mnt/bar').with(recursive: true)
      end
      it do
        expect(chef_run).to mount_mount('/mnt/bar')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:6789:/bar',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
      it do
        expect(chef_run).to enable_mount('/mnt/bar')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:6789:/bar',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
      it do
        expect(chef_run).to umount_osl_cephfs('/mnt/bar')
          .with(
            key: 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==',
            subdir: '/bar',
            client_name: 'cephfs'
          )
      end
      it do
        expect(chef_run).to delete_file('ceph.client secret for /mnt/bar')
          .with(
            path: '/etc/ceph/ceph.client.cephfs.secret',
            sensitive: true
          )
      end
      it do
        expect(chef_run).to umount_mount('/mnt/bar')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:6789:/bar',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
      it do
        expect(chef_run).to disable_mount('/mnt/bar')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:6789:/bar',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
    end
  end
end
