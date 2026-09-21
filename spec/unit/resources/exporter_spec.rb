require_relative '../../spec_helper'

describe 'osl_ceph_exporter' do
  platform 'almalinux', '8'
  cached(:subject) { chef_run }
  step_into :osl_ceph_exporter

  recipe do
    osl_ceph_exporter 'default'
  end

  it do
    is_expected.to create_osl_systemd_unit_drop_in('no-mon-config').with(
      unit_name: 'ceph-exporter.service',
      content: <<~EOC
        [Service]
        ExecStart=
        ExecStart=/usr/bin/ceph-exporter -f --no-mon-config --setuser ceph --setgroup ceph
      EOC
    )
  end

  it do
    expect(chef_run.osl_systemd_unit_drop_in('no-mon-config'))
      .to notify('service[ceph-exporter.service]').to(:restart).delayed
  end

  it { is_expected.to enable_service('ceph-exporter.service') }
  it { is_expected.to start_service('ceph-exporter.service') }

  context 'restart' do
    cached(:subject) { chef_run }

    recipe do
      osl_ceph_exporter 'default' do
        action :restart
      end
    end

    it { is_expected.to restart_service('ceph-exporter.service') }
  end
end
