resource_name :osl_ceph_install
provides :osl_ceph_install
default_action :install
unified_mode true

property :release, String, default: 'mimic'
property :mds, [true, false], default: false
property :mgr, [true, false], default: false
property :mon, [true, false], default: false
property :osd, [true, false], default: false

action :install do
  osl_repos_epel 'ceph'

  yum_repository 'ceph' do
    description "Ceph #{new_resource.release}"
    baseurl ceph_yum_baseurl
    gpgkey ceph_yum_gpgkey
  end

  package ceph_packages

  osl_firewall_ceph 'osl-ceph' if new_resource.mds || new_resource.mgr || new_resource.mon || new_resource.osd
end
