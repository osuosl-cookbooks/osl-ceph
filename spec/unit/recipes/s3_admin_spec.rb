require_relative '../../spec_helper'

describe 'osl-ceph::s3_admin' do
  ALL_PLATFORMS.each do |p|
    context "on #{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { is_expected.to_not install_package 's3cmd' }
      it { is_expected.to_not create_template '/root/.s3cfg' }
      it { is_expected.to_not create_cookbook_file '/usr/local/sbin/create-s3-bucket' }

      context 'cluster defined without rgw admin keys' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.normal['osl-ceph']['data_bag_item'] = 'cluster'
          end.converge(described_recipe)
        end

        before do
          stub_data_bag_item('ceph', 'cluster').and_return(
            'mon_key' => 'mon_key',
            'admin_key' => 'admin_key',
            'bootstrap_key' => 'bootstrap_key'
          )
        end

        it { is_expected.to_not install_package 's3cmd' }
        it { is_expected.to_not create_template '/root/.s3cfg' }
        it { is_expected.to_not create_cookbook_file '/usr/local/sbin/create-s3-bucket' }
      end

      context 'cluster defined with rgw admin keys' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.normal['osl-ceph']['data_bag_item'] = 'cluster'
          end.converge(described_recipe)
        end

        before do
          stub_data_bag_item('ceph', 'cluster').and_return(
            'mon_key' => 'mon_key',
            'admin_key' => 'admin_key',
            'bootstrap_key' => 'bootstrap_key',
            'rgw_admin_access_key' => 'TESTACCESSKEY',
            'rgw_admin_secret_key' => 'TESTSECRETKEY'
          )
        end

        it { is_expected.to include_recipe 'osl-repos::epel' }
        it { is_expected.to install_package 's3cmd' }

        it do
          is_expected.to create_template('/root/.s3cfg').with(
            owner: 'root',
            group: 'root',
            mode: '0600',
            sensitive: true
          )
        end

        it do
          is_expected.to render_file('/root/.s3cfg').with_content(<<~EOF)
            [default]
            access_key = TESTACCESSKEY
            secret_key = TESTSECRETKEY
            host_base = s3.osuosl.org
            host_bucket = %(bucket)s.s3.osuosl.org
            use_https = True
          EOF
        end

        it do
          is_expected.to create_cookbook_file('/usr/local/sbin/create-s3-bucket').with(
            owner: 'root',
            group: 'root',
            mode: '0750'
          )
        end

        context 'with a custom endpoint' do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p) do |node|
              node.normal['osl-ceph']['data_bag_item'] = 'cluster'
              node.normal['osl-ceph']['s3']['host_base'] = 'localhost:8080'
              node.normal['osl-ceph']['s3']['host_bucket'] = 'localhost:8080'
              node.normal['osl-ceph']['s3']['use_https'] = false
            end.converge(described_recipe)
          end

          it do
            is_expected.to render_file('/root/.s3cfg').with_content(<<~EOF)
              [default]
              access_key = TESTACCESSKEY
              secret_key = TESTSECRETKEY
              host_base = localhost:8080
              host_bucket = localhost:8080
              use_https = False
            EOF
          end
        end
      end
    end
  end
end
