#
# Cookbook:: osl-ceph
# Recipe:: osd
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

osl_ceph_install 'osd' do
  osd true
end

# Ensure NVMe LV's get scanned for partitions before ceph-osd starts. These DO NOT get scanned on boot because they are
# logical volumes and OSDs will fail to start if they use them.
file '/usr/local/libexec/partprobe.sh' do
  content <<~EOF
    #!/bin/bash -ex
    [ -d /dev/nvme ] && /usr/sbin/partprobe -s /dev/nvme/* || true
    [ -d /dev/nvme-1 ] && /usr/sbin/partprobe -s /dev/nvme-1/* || true
    [ -d /dev/nvme-2 ] && /usr/sbin/partprobe -s /dev/nvme-2/* || true
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

# MegaRAID reports rotational=1 for SSDs behind virtual drives, so Ceph gives
# them HDD mClock budgets and a 1 GiB BlueStore cache instead of 3 GiB.
cookbook_file '/usr/local/libexec/ceph-rotational.rb' do
  owner 'root'
  group 'root'
  mode '0750'
  notifies :restart, 'service[ceph-rotational.service]', :delayed
end

systemd_unit 'ceph-rotational.service' do
  content <<~EOF
    [Unit]
    Description=Correct rotational flag for SSDs behind MegaRAID virtual drives
    After=local-fs.target

    [Service]
    Type=oneshot
    ExecStart=/usr/local/libexec/ceph-rotational.rb
    ExecStartPre=/sbin/udevadm settle
    RemainAfterExit=yes
    TimeoutStartSec=60

    [Install]
    WantedBy=multi-user.target
  EOF
  action :create
  notifies :restart, 'service[ceph-rotational.service]', :delayed
end

# Ordering must go on the OSD templates: both units are otherwise only ordered
# before ceph.target. Wants, not Requires, so a failure cannot block the OSDs.
%w(ceph-osd@.service ceph-volume@.service).each do |unit|
  osl_systemd_unit_drop_in "rotational-#{unit}" do
    override_name 'rotational'
    unit_name unit
    content({
              'Unit' => {
                'Wants' => 'ceph-rotational.service',
                'After' => 'ceph-rotational.service',
              },
            })
  end
end

service 'ceph-rotational.service' do
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
