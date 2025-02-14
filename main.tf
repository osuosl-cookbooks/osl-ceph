resource "openstack_networking_network_v2" "ceph_network" {
    name                  = "osl_ceph_network"
    admin_state_up        = "true"
}

resource "openstack_networking_subnet_v2" "ceph_subnet" {
    network_id      = openstack_networking_network_v2.ceph_network.id
    cidr            = "10.1.2.0/24"
    enable_dhcp     = "false"
    no_gateway      = "true"
}

resource "openstack_networking_port_v2" "chef_zero" {
    name            = "chef_zero"
    admin_state_up  = true
    network_id      = data.openstack_networking_network_v2.network.id
}

resource "openstack_compute_instance_v2" "chef_zero" {
    name            = "chef-zero"
    image_name      = var.docker_image
    flavor_name     = "m2.local.2c3m10d"
    key_pair        = var.ssh_key_name
    security_groups = ["default"]
    connection {
        user = var.ssh_user_name
        host = openstack_networking_port_v2.chef_zero.all_fixed_ips.0
    }
    network {
        port = openstack_networking_port_v2.chef_zero.id
    }
    provisioner "remote-exec" {
        inline = [
            "until [ -S /var/run/docker.sock ] ; do sleep 1 && echo 'docker not started...' ; done",
            "sudo docker run -d -p 8889:8889 --name chef-zero osuosl/chef-zero"
        ]
    }

    provisioner "local-exec" {
        command = "rake knife_upload"
        environment = {
            CHEF_SERVER = "${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}"
        }
    }
}

resource "openstack_networking_port_v2" "node1" {
    name            = "node1"
    admin_state_up  = true
    network_id      = data.openstack_networking_network_v2.network.id
}

resource "openstack_networking_port_v2" "node2" {
    name            = "node2"
    admin_state_up  = true
    network_id      = data.openstack_networking_network_v2.network.id
}

resource "openstack_networking_port_v2" "node3" {
    name            = "node3"
    admin_state_up  = true
    network_id      = data.openstack_networking_network_v2.network.id
}

resource "openstack_networking_port_v2" "cephfs_client" {
    name            = "cephfs_client"
    admin_state_up  = true
    network_id      = data.openstack_networking_network_v2.network.id
}

resource "openstack_networking_port_v2" "node1_ceph" {
    name                  = "node1_ceph"
    admin_state_up        = true
    port_security_enabled = false
    network_id            = openstack_networking_network_v2.ceph_network.id
    fixed_ip {
        subnet_id = openstack_networking_subnet_v2.ceph_subnet.id
        ip_address = "10.1.2.10"
    }
}

resource "openstack_networking_port_v2" "node2_ceph" {
    name                  = "node2_ceph"
    admin_state_up        = true
    port_security_enabled = false
    network_id            = openstack_networking_network_v2.ceph_network.id
    fixed_ip {
        subnet_id = openstack_networking_subnet_v2.ceph_subnet.id
        ip_address = "10.1.2.11"
    }
}

resource "openstack_networking_port_v2" "node3_ceph" {
    name                  = "node3_ceph"
    admin_state_up        = true
    port_security_enabled = false
    network_id            = openstack_networking_network_v2.ceph_network.id
    fixed_ip {
        subnet_id = openstack_networking_subnet_v2.ceph_subnet.id
        ip_address = "10.1.2.12"
    }
}

resource "openstack_networking_port_v2" "cephfs_client_ceph" {
    name                  = "cephfs_client_ceph"
    admin_state_up        = true
    port_security_enabled = false
    network_id            = openstack_networking_network_v2.ceph_network.id
    fixed_ip {
        subnet_id = openstack_networking_subnet_v2.ceph_subnet.id
        ip_address = "10.1.2.20"
    }
}

resource "openstack_blockstorage_volume_v3" "node1_volumes" {
  count = 3
  name  = format("node1-%02d", count.index + 1)
  size  = 1
}

resource "openstack_blockstorage_volume_v3" "node2_volumes" {
  count = 3
  name  = format("node2-%02d", count.index + 1)
  size  = 1
}

resource "openstack_blockstorage_volume_v3" "node3_volumes" {
  count = 3
  name  = format("node3-%02d", count.index + 1)
  size  = 1
}

resource "openstack_compute_volume_attach_v2" "node1_attachments" {
    count       = 3
    instance_id = openstack_compute_instance_v2.node1.id
    volume_id   = "${openstack_blockstorage_volume_v3.node1_volumes.*.id[count.index]}"
}

resource "openstack_compute_volume_attach_v2" "node2_attachments" {
    count       = 3
    instance_id = openstack_compute_instance_v2.node2.id
    volume_id   = "${openstack_blockstorage_volume_v3.node2_volumes.*.id[count.index]}"
}

resource "openstack_compute_volume_attach_v2" "node3_attachments" {
    count       = 3
    instance_id = openstack_compute_instance_v2.node3.id
    volume_id   = "${openstack_blockstorage_volume_v3.node3_volumes.*.id[count.index]}"
}

resource "openstack_compute_instance_v2" "node1" {
    name            = "node1"
    image_name      = var.os_image
    flavor_name     = "m2.local.4c4m50d"
    key_pair        = var.ssh_key_name
    security_groups = ["default"]
    connection {
        user = var.ssh_user_name
        host = openstack_networking_port_v2.node1.all_fixed_ips.0
    }
    network {
        port = openstack_networking_port_v2.node1.id
    }
    network {
        port = openstack_networking_port_v2.node1_ceph.id
    }
}

resource "openstack_compute_instance_v2" "node2" {
    name            = "node2"
    image_name      = var.os_image
    flavor_name     = "m2.local.4c4m50d"
    key_pair        = var.ssh_key_name
    security_groups = ["default"]
    connection {
        user = var.ssh_user_name
        host = openstack_networking_port_v2.node2.all_fixed_ips.0
    }
    network {
        port = openstack_networking_port_v2.node2.id
    }
    network {
        port = openstack_networking_port_v2.node2_ceph.id
    }
}

resource "openstack_compute_instance_v2" "node3" {
    name            = "node3"
    image_name      = var.os_image
    flavor_name     = "m2.local.4c4m50d"
    key_pair        = var.ssh_key_name
    security_groups = ["default"]
    connection {
        user = var.ssh_user_name
        host = openstack_networking_port_v2.node3.all_fixed_ips.0
    }
    network {
        port = openstack_networking_port_v2.node3.id
    }
    network {
        port = openstack_networking_port_v2.node3_ceph.id
    }
}

resource "null_resource" "node1" {
    provisioner "local-exec" {
        command = <<-EOF
            knife bootstrap -c test/chef-config/knife.rb \
                ${var.ssh_user_name}@${openstack_compute_instance_v2.node1.network.0.fixed_ip_v4} \
                --bootstrap-version ${var.chef_version} -y -N node1 --sudo \
                -r 'role[ceph],role[ceph_mon],role[ceph_mgr],role[ceph_osd],role[ceph_mds],role[ceph_radosgw],recipe[ceph_test::multinode_node1]'
            EOF
        environment = {
            CHEF_SERVER = "${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}"
        }
    }
    depends_on = [
        openstack_compute_instance_v2.node1,
        openstack_compute_volume_attach_v2.node1_attachments
    ]
}

resource "null_resource" "node2" {
    provisioner "local-exec" {
        command = <<-EOF
            knife bootstrap -c test/chef-config/knife.rb \
                ${var.ssh_user_name}@${openstack_compute_instance_v2.node2.network.0.fixed_ip_v4} \
                --bootstrap-version ${var.chef_version} -y -N node2 --sudo \
                -r 'role[ceph],role[ceph_mon],role[ceph_mgr],role[ceph_osd],role[ceph_mds],role[ceph_radosgw]'
            EOF
        environment = {
            CHEF_SERVER = "${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}"
        }
    }
    depends_on = [
        openstack_compute_instance_v2.node2,
        openstack_compute_volume_attach_v2.node2_attachments,
        null_resource.node1
    ]
}

resource "null_resource" "node3" {
    provisioner "local-exec" {
        command = <<-EOF
            knife bootstrap -c test/chef-config/knife.rb \
                ${var.ssh_user_name}@${openstack_compute_instance_v2.node3.network.0.fixed_ip_v4} \
                --bootstrap-version ${var.chef_version} -y -N node3 --sudo \
                -r 'role[ceph],role[ceph_mon],role[ceph_mgr],role[ceph_osd],role[ceph_mds],role[ceph_radosgw],recipe[ceph_test::multinode_cephfs]'
            EOF
        environment = {
            CHEF_SERVER = "${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}"
        }
    }
    depends_on = [
        openstack_compute_instance_v2.node3,
        openstack_compute_volume_attach_v2.node3_attachments,
        null_resource.node2
    ]
}


resource "openstack_compute_instance_v2" "cephfs_client" {
    name            = "cephfs_client"
    image_name      = var.os_image
    flavor_name     = "m2.local.2c3m10d"
    key_pair        = var.ssh_key_name
    security_groups = ["default"]
    connection {
        user = var.ssh_user_name
        host = openstack_networking_port_v2.cephfs_client.all_fixed_ips.0
    }
    network {
        port = openstack_networking_port_v2.cephfs_client.id
    }
    network {
        port = openstack_networking_port_v2.cephfs_client_ceph.id
    }
    provisioner "remote-exec" {
        inline = ["echo online"]
    }
}

resource "null_resource" "cephfs_client" {
    provisioner "local-exec" {
        command = <<-EOF
            knife bootstrap -c test/chef-config/knife.rb \
                ${var.ssh_user_name}@${openstack_compute_instance_v2.cephfs_client.network.0.fixed_ip_v4} \
                --bootstrap-version ${var.chef_version} -y -N cephfs_client --sudo \
                -r 'recipe[ceph_test::multinode_client]'
            EOF
        environment = {
            CHEF_SERVER = "${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}"
        }
    }
    depends_on = [
        openstack_compute_instance_v2.cephfs_client,
        null_resource.node3
    ]
}
