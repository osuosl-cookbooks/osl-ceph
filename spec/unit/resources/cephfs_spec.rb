require_relative '../../spec_helper'

describe 'ceph_test::spec_cephfs' do
  ALL_PLATFORMS.each do |p|
    context "on #{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p.merge(step_into: 'osl_cephfs')).converge(described_recipe)
      end

      before do
        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read).with('/etc/ceph/ceph.conf').and_return('mon host = 10.0.0.2')
      end

      it do
        is_expected.to mount_osl_cephfs('/mnt/ceph')
          .with(
            key: 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==',
            client_name: 'cephfs'
          )
      end
      it do
        is_expected.to create_file('ceph.client secret for /mnt/ceph')
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
        is_expected.to create_directory('/mnt/ceph').with(recursive: true)
      end
      it do
        is_expected.to mount_mount('/mnt/ceph')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2://',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
      it do
        is_expected.to enable_mount('/mnt/ceph')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2://',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
      it do
        is_expected.to mount_osl_cephfs('/mnt/foo')
          .with(
            key: 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==',
            subdir: '/foo',
            client_name: 'cephfs'
          )
      end
      it do
        is_expected.to create_file('ceph.client secret for /mnt/foo')
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
        is_expected.to create_directory('/mnt/foo').with(recursive: true)
      end
      it do
        is_expected.to mount_mount('/mnt/foo')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:/foo',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
      it do
        is_expected.to enable_mount('/mnt/foo')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:/foo',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
      it do
        is_expected.to mount_osl_cephfs('/mnt/bar')
          .with(
            key: 'AQB3sfxaorsvKhAAkS7kVr01tZQNT1u0mhS1oQ==',
            subdir: '/bar',
            client_name: 'cephfs'
          )
      end
      it do
        is_expected.to create_file('ceph.client secret for /mnt/bar')
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
        is_expected.to create_directory('/mnt/bar').with(recursive: true)
      end
      it do
        is_expected.to mount_mount('/mnt/bar')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:/bar',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
      it do
        is_expected.to enable_mount('/mnt/bar')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:/bar',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret'],
            dump: 0,
            pass: 0
          )
      end
      it do
        is_expected.to mount_mount('/mnt/options')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2://',
            options: ['_netdev', 'name=cephfs', 'secretfile=/etc/ceph/ceph.client.cephfs.secret', 'ro'],
            dump: 0,
            pass: 0
          )
      end
      it do
        is_expected.to umount_osl_cephfs('/mnt/umount').with(client_name: 'cephfs')
      end
      it do
        is_expected.to delete_file('ceph.client secret for /mnt/umount')
          .with(path: '/etc/ceph/ceph.client.cephfs.secret')
      end
      it do
        is_expected.to umount_mount('/mnt/umount')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:/',
            dump: 0,
            pass: 0
          )
      end
      it do
        is_expected.to disable_mount('/mnt/umount')
          .with(
            fstype: 'ceph',
            device: '10.0.0.2:/',
            dump: 0,
            pass: 0
          )
      end
    end
  end
end
