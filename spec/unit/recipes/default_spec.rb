require_relative '../../spec_helper'

describe 'osl-ceph::default' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      include_context 'chef_server', p
      include_context 'common_stubs'
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to create_yum_repository('ceph').with(baseurl: /luminous/)
      end
      context 'ppc64le' do
        include_context 'chef_server', p, 'ppc64le'
        it do
          expect(chef_run).to create_yum_repository('ceph')
            .with(
              baseurl: 'http://ftp.osuosl.org/pub/osl/repos/yum/openpower/centos-$releasever/ppc64le/ceph-luminous/',
              gpgkey: 'http://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl'
            )
        end
      end
    end
  end
end
