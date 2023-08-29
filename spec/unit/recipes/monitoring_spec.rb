require_relative '../../spec_helper'

describe 'osl-ceph::monitoring' do
  platform 'centos', '7'
  cached(:subject) { chef_run }

  before do
    stub_data_bag_item('ceph', 'nagios').and_return(
       'nagios_token' => {
         'x86' => 'x86_key',
         'ppc64' => 'ppc64_key',
       }
     )
  end

  it do
    is_expected.to sync_git("#{Chef::Config[:file_cache_path]}/ceph-nagios")
      .with(
        repository: 'https://github.com/osuosl/ceph-nagios-plugins.git',
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
  it do
    is_expected.to create_ceph_keyring('nagios')
      .with(
        key: 'x86_key',
        owner: 'nrpe',
        group: 'nrpe'
      )
  end
  it do
    is_expected.to modify_group('ceph')
      .with(
        append: true,
        members: %w(nrpe)
      )
  end
  it do
    expect(chef_run.group('ceph')).to notify('service[nrpe]').to(:restart)
  end
  it do
    is_expected.to add_nrpe_check('check_ceph_osd')
      .with(
        command: '/usr/lib64/nagios/plugins/check_ceph_osd',
        parameters: '-i nagios -C 1 -H 10.0.0.2'
      )
  end
  it do
    is_expected.to add_nrpe_check('check_ceph_mon')
      .with(
        command: '/usr/lib64/nagios/plugins/check_ceph_mon',
        parameters: '-i nagios -m 10.0.0.2 -I Fauxhai'
      )
  end
end
