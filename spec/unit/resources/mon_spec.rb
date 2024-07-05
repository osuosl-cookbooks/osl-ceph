require_relative '../../spec_helper'

describe 'osl_ceph_mon' do
  platform 'almalinux', '8'
  cached(:subject) { chef_run }
  step_into :osl_ceph_mon

  before do
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with('/etc/ceph/ceph.conf').and_return('fsid = c7f0a62c-909c-4089-bce9-83d6b2bacf88')
  end

  recipe do
    osl_ceph_mon 'default'
  end

  it do
    is_expected.to run_execute('create mon keyring').with(
      user: 'ceph',
      group: 'ceph',
      command: "ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'",
      sensitive: true,
      creates: '/var/lib/ceph/mon/ceph-Fauxhai/done'
    )
  end

  it do
    is_expected.to run_execute('create admin keyring').with(
      command: "ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin   --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'\n",
      sensitive: true,
      creates: '/var/lib/ceph/mon/ceph-Fauxhai/done'
    )
  end

  it do
    is_expected.to run_execute('create bootstrap-osd keyring').with(
      command: "ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring   --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'\n",
      sensitive: true,
      creates: '/var/lib/ceph/mon/ceph-Fauxhai/done'
    )
  end

  it do
    is_expected.to run_execute('import admin key').with(
      command: 'ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring',
      sensitive: true,
      creates: '/var/lib/ceph/mon/ceph-Fauxhai/done'
    )
  end

  it do
    is_expected.to run_execute('import boostrap-osd key').with(
      command: 'ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring',
      sensitive: true,
      creates: '/var/lib/ceph/mon/ceph-Fauxhai/done'
    )
  end

  it do
    is_expected.to create_directory('/var/lib/ceph/mon/ceph-Fauxhai').with(
      owner: 'ceph',
      group: 'ceph'
    )
  end

  it do
    is_expected.to run_execute('generate monitor map').with(
      command: "monmaptool --create --add   Fauxhai 10.0.0.2 --fsid c7f0a62c-909c-4089-bce9-83d6b2bacf88 /etc/ceph/monmap\n",
      sensitive: true,
      creates: '/etc/ceph/monmap'
    )
  end

  %w(
   /etc/ceph/ceph.client.admin.keyring
   /var/lib/ceph/bootstrap-osd/ceph.keyring
   /etc/ceph/monmap
  ).each do |f|
    it { is_expected.to create_file(f).with(owner: 'ceph', group: 'ceph') }
  end

  it do
    is_expected.to run_execute('populate monitor map').with(
      user: 'ceph',
      group: 'ceph',
      command: "ceph-mon --mkfs -i Fauxhai --monmap /etc/ceph/monmap --keyring /tmp/ceph.mon.keyring\ntouch /var/lib/ceph/mon/ceph-Fauxhai/done\n",
      sensitive: true,
      creates: '/var/lib/ceph/mon/ceph-Fauxhai/done'
    )
  end

  it { is_expected.to enable_service('ceph-mon@Fauxhai.service') }
  it { is_expected.to start_service('ceph-mon@Fauxhai.service') }
  it { is_expected.to delete_file('/tmp/ceph.mon.keyring').with(sensitive: true) }

  context 'set ipaddress' do
    cached(:subject) { chef_run }

    recipe do
      osl_ceph_mon 'default' do
        ipaddress '192.168.100.100'
      end
    end

    it do
      is_expected.to run_execute('generate monitor map').with(
        command: "monmaptool --create --add   Fauxhai 192.168.100.100 --fsid c7f0a62c-909c-4089-bce9-83d6b2bacf88 /etc/ceph/monmap\n",
        sensitive: true,
        creates: '/etc/ceph/monmap'
      )
    end
  end

  context 'set keys' do
    cached(:subject) { chef_run }

    recipe do
      osl_ceph_mon 'default' do
        mon_key 'AQBkf+ZkFIMSLxAAnYRXnc/CaUdHChGCxyH3IQ=='
        admin_key 'AQBkf+Zkw67WNBAAzK7M8SnedPLkYXIanbWNCg=='
        bootstrap_key 'AQBkf+Zk+GsrOxAA1xYwZeLRB5gLI42lmjGV+A=='
        generate_monmap false
      end
    end

    it do
      is_expected.to run_execute('create mon keyring').with(
        user: 'ceph',
        group: 'ceph',
        command: "ceph-authtool --create-keyring /tmp/ceph.mon.keyring --add-key=AQBkf+ZkFIMSLxAAnYRXnc/CaUdHChGCxyH3IQ== -n mon. --cap mon 'allow *'",
        sensitive: true,
        creates: '/var/lib/ceph/mon/ceph-Fauxhai/done'
      )
    end

    it do
      is_expected.to run_execute('create admin keyring').with(
        command: "ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --add-key=AQBkf+Zkw67WNBAAzK7M8SnedPLkYXIanbWNCg== -n client.admin   --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'\n",
        sensitive: true,
        creates: '/var/lib/ceph/mon/ceph-Fauxhai/done'
      )
    end

    it do
      is_expected.to run_execute('create bootstrap-osd keyring').with(
        command: "ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring   --add-key=AQBkf+Zk+GsrOxAA1xYwZeLRB5gLI42lmjGV+A== -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'\n",
        sensitive: true,
        creates: '/var/lib/ceph/mon/ceph-Fauxhai/done'
      )
    end

    it do
      is_expected.to run_execute('populate monitor map').with(
        user: 'ceph',
        group: 'ceph',
        command: "ceph-mon --mkfs -i Fauxhai --keyring /tmp/ceph.mon.keyring\ntouch /var/lib/ceph/mon/ceph-Fauxhai/done\n",
        sensitive: true,
        creates: '/var/lib/ceph/mon/ceph-Fauxhai/done'
      )
    end

    it { is_expected.to_not run_execute('generate monitor map') }
    it { is_expected.to_not create_file('/etc/ceph/monmap') }
  end
end
