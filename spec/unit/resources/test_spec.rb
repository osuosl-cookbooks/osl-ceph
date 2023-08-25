require_relative '../../spec_helper'

describe 'osl_ceph_test' do
  platform 'centos', '7'
  cached(:subject) { chef_run }
  step_into :osl_ceph_test

  recipe do
    osl_ceph_test 'default'
  end

  before do
    stub_command('vgs osd0').and_return(false)
    stub_command('vgs osd1').and_return(false)
    stub_command('vgs osd2').and_return(false)
  end

  it do
    is_expected.to install_osl_ceph_install('test').with(
      mds: false,
      mgr: true,
      mon: true,
      osd: true
    )
  end

  it do
    is_expected.to create_osl_ceph_config('test').with(
      fsid: 'ae3f1d03-bacd-4a90-b869-1a4fabb107f2',
      mon_initial_members: %w(Fauxhai),
      mon_host: %w(10.0.0.2),
      public_network: %w(10.1.100.0/23),
      cluster_network: %w(10.1.100.0/23)
    )
  end

  it { is_expected.to start_osl_ceph_mon 'test' }
  it { is_expected.to start_osl_ceph_mgr 'test' }
  it { is_expected.to_not start_osl_ceph_mds 'test' }
  it { is_expected.to create_template('/var/tmp/crush_map_decompressed').with(cookbook: 'osl-ceph') }

  it do
    is_expected.to run_execute('update crush map').with(
      command: "crushtool -c crush_map_decompressed -o new_crush_map_compressed\nceph osd setcrushmap -i new_crush_map_compressed\ntouch /var/tmp/new_crush_map_compressed.done\n",
      creates: '/var/tmp/new_crush_map_compressed.done'
    )
  end

  %w(0 1 2).each do |i|
    it do
      is_expected.to run_execute("create osd#{i}").with(
        command: "dd if=/dev/zero of=/root/osd#{i} bs=1G count=1\nvgcreate osd#{i} $(losetup --show -f /root/osd#{i})\nlvcreate -n osd#{i} -l 100%FREE osd#{i}\nceph-volume lvm create --bluestore --data osd#{i}/osd#{i}\n"
      )
    end
  end

  context 'cephfs' do
    cached(:subject) { chef_run }

    recipe do
      osl_ceph_test 'default' do
        cephfs true
      end
    end

    it { is_expected.to start_osl_ceph_mds 'test' }

    it do
      is_expected.to run_execute('create cephfs').with(
        command: "ceph osd pool create cephfs_data 32\nceph osd pool create cephfs_metadata 32\nceph fs new cephfs cephfs_metadata cephfs_data\ntouch /root/cephfs.done\n",
        creates: '/root/cephfs.done'
      )
    end

    it { is_expected.to run_ruby_block 'wait for ceph mds cluster' }
  end

  context 'config' do
    cached(:subject) { chef_run }

    recipe do
      osl_ceph_test 'default' do
        config({
          'fsid' => '0fdfedf4-553a-405a-b65f-2e9f62bbfc22',
          'mon_initial_members' => %w(node1),
          'mon_host' => %w(10.0.0.1),
          'public_network' => %w(10.0.0.0/24),
          'cluster_network' => %w(10.0.0.0/24),
        })
      end
    end

    it do
      is_expected.to create_osl_ceph_config('test').with(
        fsid: '0fdfedf4-553a-405a-b65f-2e9f62bbfc22',
        mon_initial_members: %w(node1),
        mon_host: %w(10.0.0.1),
        public_network: %w(10.0.0.0/24),
        cluster_network: %w(10.0.0.0/24)
      )
    end
  end

  context 'osd_size' do
    cached(:subject) { chef_run }

    recipe do
      osl_ceph_test 'default' do
        osd_size '10G'
      end
    end

    %w(0 1 2).each do |i|
      it do
        is_expected.to run_execute("create osd#{i}").with(
          command: "dd if=/dev/zero of=/root/osd#{i} bs=10G count=1\nvgcreate osd#{i} $(losetup --show -f /root/osd#{i})\nlvcreate -n osd#{i} -l 100%FREE osd#{i}\nceph-volume lvm create --bluestore --data osd#{i}/osd#{i}\n"
        )
      end
    end
  end
end
