require_relative '../../spec_helper'

describe 'osl-ceph::mgr' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      include_context 'chef_server', p
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to create_systemd_service_drop_in('ceph-mgr@')
          .with(
            service_restart_sec: 10,
            unit_start_limit_burst: 5,
            override: 'ceph-mgr@.service'
          )
      end
    end
  end
end
