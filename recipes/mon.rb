#
# Cookbook:: osl-ceph
# Recipe:: mon
#
# Copyright:: 2018-2021, Oregon State University
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
include_recipe 'ceph-chef::mon'
include_recipe 'ceph-chef::mon_start'

delete_resource(:cookbook_file, '/etc/systemd/system/ceph-mon@.service')
delete_resource(:execute, 'change-ceph-conf-perm')
tag(node['ceph']['admin']['tag'])
tag(node['ceph']['mon']['tag'])
