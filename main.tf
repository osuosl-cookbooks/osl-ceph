resource "openstack_compute_instance_v2" "chef_zero" {
    name            = "chef-zero"
    image_name      = "${var.centos_atomic_image}"
    flavor_name     = "m1.small"
    key_pair        = "${var.ssh_key_name}"
    security_groups = ["default"]
    connection {
        user = "centos"
    }
    network {
        uuid = "${data.openstack_networking_network_v2.network.id}"
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

resource "openstack_compute_instance_v2" "node1" {
    name            = "node1"
    image_name      = "${var.centos_image}"
    flavor_name     = "m1.large"
    key_pair        = "${var.ssh_key_name}"
    security_groups = ["default"]
    connection {
        user = "centos"
    }
    network {
        uuid = "${data.openstack_networking_network_v2.network.id}"
    }
    provisioner "chef" {
        run_list        = [ "role[ceph]", "role[ceph_mon]", "role[ceph_mgr]", "role[ceph_osd]", "role[ceph_mds]" ]
        node_name       = "node1"
        secret_key      = "${file("test/integration/encrypted_data_bag_secret")}"
        server_url      = "http://${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}:8889"
        recreate_client = true
        user_name       = "fakeclient"
        user_key        = "${file("test/chef-config/fakeclient.pem")}"
        version         = "${var.chef_version}"
    }
}

resource "openstack_compute_instance_v2" "node2" {
    name            = "node2"
    image_name      = "${var.centos_image}"
    flavor_name     = "m1.large"
    key_pair        = "${var.ssh_key_name}"
    security_groups = ["default"]
    connection {
        user = "centos"
    }
    network {
        uuid = "${data.openstack_networking_network_v2.network.id}"
    }
    provisioner "chef" {
        attributes_json = <<EOF
            {
                "osl-ceph": {
                    "filesystem-osd-ids": [ 3, 4, 5 ]
                }
            }
        EOF
        run_list        = [ "role[ceph]", "role[ceph_mon]", "role[ceph_mgr]", "role[ceph_osd]", "role[ceph_mds]" ]
        node_name       = "node2"
        secret_key      = "${file("test/integration/encrypted_data_bag_secret")}"
        server_url      = "http://${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}:8889"
        recreate_client = true
        user_name       = "fakeclient"
        user_key        = "${file("test/chef-config/fakeclient.pem")}"
        version         = "${var.chef_version}"
    }
    depends_on = [ "openstack_compute_instance_v2.node1" ]
}

resource "openstack_compute_instance_v2" "node3" {
    name            = "node3"
    image_name      = "${var.centos_image}"
    flavor_name     = "m1.large"
    key_pair        = "${var.ssh_key_name}"
    security_groups = ["default"]
    connection {
        user = "centos"
    }
    network {
        uuid = "${data.openstack_networking_network_v2.network.id}"
    }
    provisioner "chef" {
        attributes_json = <<EOF
            {
                "osl-ceph": {
                    "filesystem-osd-ids": [ 6, 7, 8 ]
                },
                "ceph_test": {
                    "pg_num": 128
                }
            }
        EOF
        run_list        = [
            "role[ceph]",
            "role[ceph_mon]",
            "role[ceph_mgr]",
            "role[ceph_osd]",
            "role[ceph_mds]",
            "recipe[ceph_test::pool_setup]",
            "recipe[ceph_test::mds_setup]"
        ]
        node_name       = "node3"
        secret_key      = "${file("test/integration/encrypted_data_bag_secret")}"
        server_url      = "http://${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}:8889"
        recreate_client = true
        user_name       = "fakeclient"
        user_key        = "${file("test/chef-config/fakeclient.pem")}"
        version         = "${var.chef_version}"
    }
    depends_on = [ "openstack_compute_instance_v2.node2" ]
}

resource "openstack_compute_instance_v2" "cephfs_client" {
    name            = "cephfs_client"
    image_name      = "${var.centos_image}"
    flavor_name     = "m1.small"
    key_pair        = "${var.ssh_key_name}"
    security_groups = ["default"]
    connection {
        user = "centos"
    }
    network {
        uuid = "${data.openstack_networking_network_v2.network.id}"
    }
    provisioner "chef" {
        run_list        = [
            "role[ceph]",
            "recipe[ceph_test::mds]"
        ]
        node_name       = "cephfs_client"
        secret_key      = "${file("test/integration/encrypted_data_bag_secret")}"
        server_url      = "http://${openstack_compute_instance_v2.chef_zero.network.0.fixed_ip_v4}:8889"
        recreate_client = true
        user_name       = "fakeclient"
        user_key        = "${file("test/chef-config/fakeclient.pem")}"
        version         = "${var.chef_version}"
    }
    depends_on = [ "openstack_compute_instance_v2.node3" ]
}
