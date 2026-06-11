#
# Cookbook:: osl-ceph
# Recipe:: s3_admin
#
# Copyright:: 2026, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
if node['osl-ceph']['data_bag_item']
  secrets = data_bag_item('ceph', node['osl-ceph']['data_bag_item'])

  if secrets['rgw_admin_access_key'] && secrets['rgw_admin_secret_key']
    include_recipe 'osl-repos::epel'

    package 's3cmd'

    s3 = node['osl-ceph']['s3']

    template '/root/.s3cfg' do
      source 's3cfg.erb'
      owner 'root'
      group 'root'
      mode '0600'
      sensitive true
      variables(
        access_key: secrets['rgw_admin_access_key'],
        secret_key: secrets['rgw_admin_secret_key'],
        host_base: s3['host_base'],
        host_bucket: s3['host_bucket'] || "%(bucket)s.#{s3['host_base']}",
        use_https: s3['use_https']
      )
    end

    cookbook_file '/usr/local/sbin/create-s3-bucket' do
      owner 'root'
      group 'root'
      mode '0750'
    end
  end
end
