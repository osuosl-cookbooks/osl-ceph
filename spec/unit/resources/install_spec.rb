require_relative '../../spec_helper'

describe 'osl_ceph_install' do
  platform 'almalinux', '8'
  cached(:subject) { chef_run }
  step_into :osl_ceph_install

  recipe do
    osl_ceph_install 'default'
  end

  it { is_expected.to add_osl_repos_epel 'ceph' }

  it do
    is_expected.to create_yum_repository('ceph').with(
      description: 'Ceph quincy',
      baseurl: 'https://download.ceph.com/rpm-quincy/el$releasever/$basearch',
      gpgkey: 'https://download.ceph.com/keys/release.asc'
    )
  end

  it do
    is_expected.to create_yum_repository('ceph-noarch').with(
      description: 'Ceph noarch quincy',
      baseurl: 'https://download.ceph.com/rpm-quincy/el$releasever/noarch',
      gpgkey: 'https://download.ceph.com/keys/release.asc'
    )
  end

  it { is_expected.to install_package(%w(ceph-common ceph-selinux)) }
  it { is_expected.to_not accept_osl_firewall_ceph 'osl-ceph' }

  context 'ppc64le' do
    automatic_attributes['kernel']['machine'] = 'ppc64le'
    cached(:subject) { chef_run }

    it do
      is_expected.to create_yum_repository('ceph').with(
        description: 'Ceph quincy',
        baseurl: 'https://ftp.osuosl.org/pub/osl/repos/yum/$releasever/ceph-quincy/$basearch',
        gpgkey: 'https://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl'
      )
    end
  end

  context 'mds' do
    cached(:subject) { chef_run }

    recipe do
      osl_ceph_install 'default' do
        mds true
      end
    end

    it { is_expected.to install_package(%w(ceph-common ceph-mds ceph-selinux)) }
    it { is_expected.to accept_osl_firewall_ceph 'osl-ceph' }
  end

  context 'mgr' do
    cached(:subject) { chef_run }

    recipe do
      osl_ceph_install 'default' do
        mgr true
      end
    end

    it { is_expected.to install_package(%w(ceph-common ceph-mgr ceph-mgr-dashboard ceph-mgr-diskprediction-local ceph-selinux)) }
    it { is_expected.to accept_osl_firewall_ceph 'osl-ceph' }
  end

  context 'mon' do
    cached(:subject) { chef_run }

    recipe do
      osl_ceph_install 'default' do
        mon true
      end
    end

    it { is_expected.to install_package(%w(ceph-common ceph-mon ceph-selinux)) }
    it { is_expected.to accept_osl_firewall_ceph 'osl-ceph' }
  end

  context 'osd' do
    cached(:subject) { chef_run }

    recipe do
      osl_ceph_install 'default' do
        osd true
      end
    end

    it { is_expected.to install_package(%w(ceph-common ceph-osd ceph-selinux)) }
    it { is_expected.to accept_osl_firewall_ceph 'osl-ceph' }
  end

  context 'all' do
    cached(:subject) { chef_run }

    recipe do
      osl_ceph_install 'default' do
        mds true
        mgr true
        mon true
        osd true
      end
    end

    it { is_expected.to install_package(%w(ceph-common ceph-mds ceph-mgr ceph-mgr-dashboard ceph-mgr-diskprediction-local ceph-mon ceph-osd ceph-selinux)) }
    it { is_expected.to accept_osl_firewall_ceph 'osl-ceph' }
  end
end
