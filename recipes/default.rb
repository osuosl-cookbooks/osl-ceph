#
# Cookbook:: osl-ceph
# Recipe:: default
#
# Copyright:: 2017-2021, Oregon State University
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
node.default['ceph']['version'] = 'mimic'
node.default['ceph']['mgr']['enable'] = true
node.default['ceph']['osd']['type'] = 'bluestore'
node.default['ceph']['init_style'] = 'systemd'
%w(mds mon osd radosgw rbd).each do |s|
  node.default['ceph'][s]['init_style'] = 'systemd'
end

if node['kernel']['machine'] == 'ppc64le'
  node.override['ceph']['rhel']['stable']['repository'] =
    "http://ftp.osuosl.org/pub/osl/repos/yum/$releasever/ceph-#{node['ceph']['version']}/ppc64le"
  node.override['ceph']['rhel']['stable']['repository_key'] =
    'http://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl'
end

osl_firewall_ceph 'osl-ceph'

include_recipe 'ceph-chef'
include_recipe 'ceph-chef::repo'

delete_resource(:execute, 'change-ceph-conf-perm')

directory 'Set /etc/ceph owner/group' do
  owner node['ceph']['owner']
  group node['ceph']['group']
  path '/etc/ceph'
  mode '0750'
end
