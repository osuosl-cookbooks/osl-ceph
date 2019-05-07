output "chef_zero" {
    value = "${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}"
}
output "node1" {
    value = "${openstack_compute_instance_v2.node1.network.0.fixed_ip_v4}"
}
output "node2" {
    value = "${openstack_compute_instance_v2.node2.network.0.fixed_ip_v4}"
}
output "node3" {
    value = "${openstack_compute_instance_v2.node3.network.0.fixed_ip_v4}"
}
output "cephfs_client" {
    value = "${openstack_compute_instance_v2.cephfs_client.network.0.fixed_ip_v4}"
}
output "ceph_nodes" {
    value = [
        "${openstack_compute_instance_v2.node1.network.0.fixed_ip_v4}",
        "${openstack_compute_instance_v2.node2.network.0.fixed_ip_v4}",
        "${openstack_compute_instance_v2.node3.network.0.fixed_ip_v4}"
    ]
}
