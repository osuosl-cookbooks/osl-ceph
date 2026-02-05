#
# Cookbook:: osl-ceph
# Recipe:: nagios
#
# Copyright:: 2018-2026, Oregon State University
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

include_recipe 'osl-ceph'
include_recipe 'osl-nrpe'
include_recipe 'osl-git'

ceph_nagios = ::File.join(Chef::Config[:file_cache_path], 'ceph-nagios')

git ceph_nagios do
  repository 'https://github.com/osuosl/ceph-nagios-plugins.git'
  revision 'reef'
  ignore_failure true
end

%w(
  check_ceph_df
  check_ceph_health
  check_ceph_mds
  check_ceph_mon
  check_ceph_osd
  check_ceph_rgw
).each do |check|
  link ::File.join(node['nrpe']['plugin_dir'], check) do
    to ::File.join(ceph_nagios, 'src', check)
  end
end
