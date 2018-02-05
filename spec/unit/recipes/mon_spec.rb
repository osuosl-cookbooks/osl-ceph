require_relative '../../spec_helper'

describe 'osl-ceph::mon' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      include_context 'chef_server', p
      include_context 'common_stubs'
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to_not create_cookbook_file('/etc/systemd/system/ceph-mon@.service')
      end
    end
  end
end
