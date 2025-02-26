#
# Cookbook:: osl-ceph
# Recipe:: default
#
# Copyright:: 2017-2025, Oregon State University
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

include_recipe 'osl-repos::alma'

osl_ceph_install 'default'

edit_resource(:osl_repos_alma, 'default') do
  synergy true
end

# If a config attribute is defined, create a config
config = node['osl-ceph']['config']

osl_ceph_config 'default' do
  fsid config['fsid']
  mon_initial_members config['mon_initial_members']
  mon_host config['mon_host']
  public_network config['public_network']
  cluster_network config['cluster_network']
  client_options config['client_options'] if config['client_options']
  radosgw config['radosgw'] if config['radosgw']
  rgw_dns_name config['rgw_dns_name'] if config['rgw_dns_name']
  rgw_dns_s3website_name config['rgw_dns_s3website_name'] if config['rgw_dns_s3website_name']
end unless config.empty?
