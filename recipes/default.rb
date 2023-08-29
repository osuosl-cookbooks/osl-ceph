#
# Cookbook:: osl-ceph
# Recipe:: default
#
# Copyright:: 2017-2023, Oregon State University
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

osl_ceph_install 'default'

# If a config attribute is defined, create a config
config = node['osl-ceph']['config']

osl_ceph_config 'default' do
  fsid config['fsid']
  mon_initial_members config['mon_initial_members']
  mon_host config['mon_host']
  public_network config['public_network']
  cluster_network config['cluster_network']
  client_options config['client_options'] if config['client_options']
end unless config.empty?
