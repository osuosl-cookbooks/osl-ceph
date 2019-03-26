require_relative '../../spec_helper'

describe 'osl-ceph::default' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      include_context 'chef_server', p
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to create_yum_repository('ceph').with(baseurl: /luminous/)
      end
      it do
        expect(chef_run).to create_directory('Set /etc/ceph owner/group')
          .with(
            owner: 'ceph',
            group: 'ceph',
            path: '/etc/ceph',
            mode:  '0750'
          )
      end
      context 'ppc64le' do
        include_context 'chef_server', p, 'ppc64le'
        it do
          expect(chef_run).to create_yum_repository('ceph')
            .with(
              baseurl: 'http://ftp.osuosl.org/pub/osl/repos/yum/$releasever/ceph-luminous/ppc64le',
              gpgkey: 'http://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl'
            )
        end
      end
    end
  end
end
