#
# Cookbook:: osl-ceph
# Recipe:: osd
#
# Copyright:: 2018-2025, Oregon State University
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

# Ensure NVMe LV's get scanned for partitions before ceph-osd starts. These DO NOT get scanned on boot because they are
# logical volumes and OSDs will fail to start if they use them.
file '/usr/local/libexec/partprobe.sh' do
  content <<~EOF
    #!/bin/bash -ex
    [ -d /dev/nvme ] && /usr/sbin/partprobe -s /dev/nvme/* || true
  EOF
  mode '0750'
end

systemd_unit 'partprobe.service' do
  content <<~EOF
    [Unit]
    Description=Run partprobe on devices before starting Ceph
    After=local-fs.target lvm2-pvscan@.service
    Before=ceph.target

    [Service]
    Type=oneshot
    ExecStart=/usr/local/libexec/partprobe.sh
    ExecStartPre=/sbin/udevadm settle
    RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target
  EOF
  action :create
end

service 'partprobe.service' do
  action [:enable, :start]
end

if node['osl-ceph']['data_bag_item']
  secrets = data_bag_item('ceph', node['osl-ceph']['data_bag_item'])

  osl_ceph_keyring 'bootstrap-osd' do
    key secrets['bootstrap_key']
  end
end

service 'ceph-osd.target' do
  action [:enable, :start]
  subscribes :restart, 'osl_ceph_config[default]'
end
