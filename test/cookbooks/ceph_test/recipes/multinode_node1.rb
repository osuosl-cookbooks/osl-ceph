# Mute these warnings:
#   HEALTH_WARN mon is allowing insecure global_id reclaim
# https://docs.ceph.com/en/latest/security/CVE-2021-20288/
execute 'disable global_id warnings' do
  command <<~EOC
    ceph config set mon auth_allow_insecure_global_id_reclaim false
    touch /root/disable_global_id
  EOC
  creates '/root/disable_global_id'
end

# Enable v2 network protocol
# https://docs.ceph.com/en/latest/rados/configuration/msgr2/#msgr2
execute 'enable msgr2' do
  command <<~EOC
    ceph mon enable-msgr2
    touch /root/enable_msgr2
  EOC
  creates '/root/enable_msgr2'
end

# Enable mgr application on .mgr pool to silence HEALTH_WARN
execute 'enable mgr application on .mgr pool' do
  command 'ceph osd pool application enable .mgr mgr'
  not_if 'ceph osd pool application get .mgr mgr'
end
