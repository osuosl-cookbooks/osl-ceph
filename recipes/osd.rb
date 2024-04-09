#
# Cookbook:: osl-ceph
# Recipe:: osd
#
# Copyright:: 2018-2024, Oregon State University
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

osl_ceph_install 'osd' do
  osd true
end

if node['osl-ceph']['data_bag_item']
  secrets = data_bag_item('ceph', node['osl-ceph']['data_bag_item'])

  osl_ceph_keyring 'bootstrap-osd' do
    key secrets['bootstrap_key']
  end
end

service 'ceph-osd.target' do
  action [:enable, :start]
end
