require_relative '../../spec_helper'

describe 'osl-ceph::nagios' do
  platform 'centos', '7'
  cached(:subject) { chef_run }

  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end
  it do
    is_expected.to sync_git("#{Chef::Config[:file_cache_path]}/ceph-nagios")
      .with(
        repository: 'https://github.com/osuosl/ceph-nagios-plugins.git',
        revision: 'nautilus',
        ignore_failure: true
      )
  end
  %w(
    check_ceph_df
    check_ceph_health
    check_ceph_mds
    check_ceph_mon
    check_ceph_osd
    check_ceph_rgw
  ).each do |check|
    it do
      is_expected.to create_link("/usr/lib64/nagios/plugins/#{check}")
        .with(to: ::File.join(Chef::Config[:file_cache_path], 'ceph-nagios', 'src', check))
    end
  end
end
