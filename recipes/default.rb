#
# Cookbook:: osl-ceph
# Recipe:: default
#
# Copyright:: 2017, Oregon State University
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
node.default['ceph']['version'] = 'luminous'
node.default['ceph']['mgr']['enable'] = true
node.default['ceph']['osd']['type'] = 'bluestore'
node.default['ceph']['init_style'] = 'systemd'
%w(mds mon osd radosgw rbd).each do |s|
  node.default['ceph'][s]['init_style'] = 'systemd'
end

if node['kernel']['machine'] == 'ppc64le'
  node.override['ceph']['rhel']['stable']['repository'] =
    "http://ftp.osuosl.org/pub/osl/repos/yum/openpower/centos-$releasever/ppc64le/ceph-#{node['ceph']['version']}/"
  node.override['ceph']['rhel']['stable']['repository_key'] =
    'http://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl'
end

include_recipe 'firewall::ceph'
include_recipe 'ceph-chef'
include_recipe 'ceph-chef::repo'

delete_resource(:execute, 'change-ceph-conf-perm')

edit_resource!(:directory, '/etc/ceph') do
  owner node['ceph']['owner']
  group node['ceph']['group']
  mode '0750'
end
