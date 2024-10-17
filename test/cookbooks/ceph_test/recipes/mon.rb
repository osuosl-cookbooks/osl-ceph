include_recipe 'ceph_test::default'

osl_ceph_install 'mon' do
  mon true
end

osl_ceph_mon 'mon' do
  subscribes :restart, 'osl_ceph_config[default]'
end

# Mute these warnings:
#   HEALTH_WARN mon is allowing insecure global_id reclaim
# https://docs.ceph.com/en/latest/security/CVE-2021-20288/
# TODO: This probably should be removed in octopus
execute 'disable global_id warnings' do
  command <<~EOC
    ceph config set mon auth_allow_insecure_global_id_reclaim false
    touch /root/disable_global_id
  EOC
  creates '/root/disable_global_id'
  live_stream true
end

# Enable v2 network protocol
# https://docs.ceph.com/en/latest/rados/configuration/msgr2/#msgr2
# TODO: This probably should be removed in octopus
execute 'enable msgr2' do
  command <<~EOC
    ceph mon enable-msgr2
    touch /root/enable_msgr2
  EOC
  creates '/root/enable_msgr2'
  live_stream true
end
