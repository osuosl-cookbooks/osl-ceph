require_relative '../../spec_helper'

describe 'osl-ceph::nagios' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      include_context 'chef_server', p
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to sync_git("#{Chef::Config[:file_cache_path]}/ceph-nagios")
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
          expect(chef_run).to create_link("/usr/lib64/nagios/plugins/#{check}")
            .with(to: ::File.join(Chef::Config[:file_cache_path], 'ceph-nagios', 'src', check))
        end
      end
    end
  end
end
