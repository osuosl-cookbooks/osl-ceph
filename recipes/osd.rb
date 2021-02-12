#
# Cookbook:: osl-ceph
# Recipe:: osd
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
include_recipe 'ceph-chef::osd'

# The following is only for test-kitchen testing purposes and NOT production
if node['osl-ceph']['create-filesystem-osd']
  node['osl-ceph']['filesystem-osd-ids'].each do |id|
    osd_device = "/var/lib/ceph/osd/ceph-#{id}"

    directory osd_device do
      recursive true
    end

    execute "ceph-disk prepare and activate on #{osd_device}" do
      command <<-EOF
        ceph-disk -v prepare #{osd_device}
        chown --verbose -R ceph. #{osd_device}
        ceph-disk -v activate --mark-init none #{osd_device}
      EOF
      creates "#{osd_device}/mkfs_done"
    end
  end
end

include_recipe 'ceph-chef::osd_start_all'
delete_resource(:execute, 'change-ceph-conf-perm')
tag(node['ceph']['osd']['tag'])
