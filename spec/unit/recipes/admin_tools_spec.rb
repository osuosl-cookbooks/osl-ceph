require_relative '../../spec_helper'

describe 'osl-ceph::admin_tools' do
  ALL_PLATFORMS.each do |p|
    context "on #{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      %w(ceph-assess ceph-metrics-assess ceph-check-rotational).each do |tool|
        it { is_expected.to create_cookbook_file("/usr/local/sbin/#{tool}").with(source: tool, mode: '0750') }
      end
    end
  end
end
