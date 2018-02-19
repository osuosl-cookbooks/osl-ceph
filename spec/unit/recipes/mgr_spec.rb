require_relative '../../spec_helper'

describe 'osl-ceph::mgr' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      include_context 'chef_server', p
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to create_systemd_service('ceph-mgr@')
          .with(
            restart_sec: 10,
            start_limit_burst: 5,
            override: 'ceph-mgr@',
            drop_in: true
          )
      end
    end
  end
end
