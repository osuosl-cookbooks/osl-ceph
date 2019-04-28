data "openstack_networking_network_v2" "network" {
    name = "${var.network}"
}
data "openstack_networking_subnet_v2" "subnet" {
    name = "${var.subnet}"
}
