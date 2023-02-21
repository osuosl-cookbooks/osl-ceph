require_relative '../../spec_helper'

describe 'osl-ceph::mgr' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      include_context 'chef_server', p
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to create_osl_systemd_unit_drop_in('ceph-mgr@')
          .with(
            unit_name: 'ceph-mgr@.service',
            content: {
              'Service' => {
                'RestartSec' => 10,
                'StartLimitBurst' => 5,
              },
            }
          )
      end
    end
  end
end
