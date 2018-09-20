#
# Cookbook:: osl-ceph
# Recipe:: monitoring
#
# Copyright:: 2018, Oregon State University
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
include_recipe 'osl-ceph::nagios'

secrets = data_bag_item('ceph', 'nagios')
arch = node['kernel']['machine'] == 'ppc64le' ? 'ppc64' : 'x86'

ceph_keyring 'nagios' do
  key secrets['nagios_token'][arch]
  owner node['nrpe']['user']
  group node['nrpe']['group']
end

group 'ceph' do
  append true
  members [node['nrpe']['user']]
  action :modify
  notifies :restart, 'service[nrpe]'
end

nrpe = node['osl-ceph']['nrpe']

nrpe_check 'check_ceph_osd' do
  command ::File.join(node['nrpe']['plugin_dir'], 'check_ceph_osd')
  parameters [
    '-i nagios',
    "-C #{nrpe['check_ceph_osd']['critical']}",
    "-H #{node['ipaddress']}",
  ].join(' ')
end

nrpe_check 'check_ceph_mon' do
  command ::File.join(node['nrpe']['plugin_dir'], 'check_ceph_mon')
  parameters "-i nagios -m #{node['ipaddress']} -I #{node['hostname']}"
end
