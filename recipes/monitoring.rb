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

keyname = "nagios-#{node['hostname']}"

ceph_chef_client keyname do
  caps(mon: 'allow r')
  keyname "client.#{keyname}"
  filename "/etc/ceph/ceph.client.#{keyname}.keyring"
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

nrpe_check 'check_ceph_df' do
  command ::File.join(node['nrpe']['plugin_dir'], 'check_ceph_df')
  parameters [
    "-i #{keyname}",
    "-m #{node['ipaddress']}",
    "-W #{nrpe['check_ceph_df']['warning']}",
    "-C #{nrpe['check_ceph_df']['critical']}"
  ].join(' ')
end

nrpe_check 'check_ceph_osd' do
  command ::File.join(node['nrpe']['plugin_dir'], 'check_ceph_osd')
  parameters [
    "-i #{keyname}",
    "-C #{nrpe['check_ceph_osd']['critical']}",
    "-H #{node['ipaddress']}"
  ].join(' ')
end

nrpe_check 'check_ceph_health' do
  command ::File.join(node['nrpe']['plugin_dir'], 'check_ceph_health')
  parameters "-i #{keyname} -m #{node['ipaddress']}"
end

nrpe_check 'check_ceph_mon' do
  command ::File.join(node['nrpe']['plugin_dir'], 'check_ceph_mon')
  parameters "-i #{keyname} -m #{node['ipaddress']} -I #{node['hostname']}"
end
