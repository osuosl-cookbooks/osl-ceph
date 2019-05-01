# osl-ceph Cookbook

OSL wrapper cookbook for upstream [ceph-chef cookbooks](https://github.com/ceph/ceph-chef/). Also includes support for
ppc64le compute nodes.

## Supported Platforms

- Ceph Luminous Release
- CentOS 7

# Multi-host test integration

This cookbook utilizes [kitchen-terraform](https://github.com/newcontext-oss/kitchen-terraform) to test deploying
various parts of this cookbook in multiple nodes, similar to that in production.

## Prereqs

- ChefDK 2.5.3
- Terraform
- kitchen-terraform
- OpenStack cluster

Ensure you have the following in your ``.bashrc`` (or similar):

``` bash
export TF_VAR_ssh_key_name="$OS_SSH_KEYPAIR"
```

## Supported Deployments

- Chef-zero node acting as a Chef Server
- Three node ceph cluster
	- Each node ceph node runs mon, mgr, mds and osd services
- One cephfs client node
  - The cephfs client node will mount cephfs from the ceph cluster

## Testing

First, generate some keys for chef-zero and then simply run the following suite.

``` console
# Only need to run this once
$ chef exec rake create_key
$ kitchen test multi-node
```

Be patient as this will take a while to converge all of the nodes (approximately 15 minutes).

## Access the nodes

Unfortunately, kitchen-terraform doesn't support using ``kitchen console`` so you will need to log into the nodes
manually. To see what their IP addresses are, just run ``terraform output`` which will output all of the IPs.

``` bash
# You can run the following commands to login to each node
$ ssh centos@$(terraform output node1)
$ ssh centos@$(terraform output node2)
$ ssh centos@$(terraform output node3)
$ ssh centos@$(terraform output cephfs_client)

# Or you can look at the IPs for all for all of the nodes at once
$ terraform output
ceph_nodes = [
    10.1.100.3,
    10.1.100.66,
    10.1.100.45
]
cephfs_client = 10.1.100.8
chef_zero = 10.1.100.43
node1 = 10.1.100.3
node2 = 10.1.100.66
node3 = 10.1.100.45
```

## Running ceph commands

Once you're logged into one of the nodes, you should be able to run the following commands:

``` bash
$ ceph -s
  cluster:
    id:     7964405e-3e4a-4aee-b5a8-bf5e4f816c5d
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node1,node3,node2
    mgr: node1(active), standbys: node2, node3
    mds: cephfs-1/1/1 up  {0=node2=up:active}, 2 up:standby
    osd: 9 osds: 9 up, 9 in

  data:
    pools:   2 pools, 256 pgs
    objects: 24 objects, 32.6KiB
    usage:   9.04GiB used, 81.0GiB / 90GiB avail
    pgs:     256 active+clean

$ ceph osd tree
ID CLASS WEIGHT  TYPE NAME      STATUS REWEIGHT PRI-AFF
-1       0.08817 root default
-3       0.02939     host node1
 0   hdd 0.00980         osd.0      up  1.00000 1.00000
 1   hdd 0.00980         osd.1      up  1.00000 1.00000
 2   hdd 0.00980         osd.2      up  1.00000 1.00000
-5       0.02939     host node2
 3   hdd 0.00980         osd.3      up  1.00000 1.00000
 4   hdd 0.00980         osd.4      up  1.00000 1.00000
 5   hdd 0.00980         osd.5      up  1.00000 1.00000
-7       0.02939     host node3
 6   hdd 0.00980         osd.6      up  1.00000 1.00000
 7   hdd 0.00980         osd.7      up  1.00000 1.00000
 8   hdd 0.00980         osd.8      up  1.00000 1.00000
```

## Interacting with the chef-zero server

All of these nodes are configured using a Chef Server which is a container running chef-zero. You can interact with the
chef-zero server by doing the following:

``` bash
$ CHEF_SERVER="$(terraform output chef_zero)" knife node list -c test/chef-config/knife.rb
cephfs_client
node1
node2
node3
$ CHEF_SERVER="$(terraform output chef_zero)" knife node edit -c test/chef-config/knife.rb
```

In addition, on any node that has been deployed, you can re-run ``chef-client`` like you normally would on a production
system. This should allow you to do development on your multi-node environment as needed. **Just make sure you include
the knife config otherwise you will be interacting with our production chef server!**

## Using Terraform directly

You do not need to use kitchen-terraform directly if you're just doing development. It's primarily useful for testing
the multi-node cluster using inspec. You can simply deploy the cluster using terraform directly by doing the following:

``` bash
# Sanity check
$ terraform plan
# Deploy the cluster
$ terraform apply
# Destroy the cluster
$ terraform destroy
```

## Cleanup

``` bash
# To remove all the nodes and start again, run the following test-kitchen command.
$ kitchen destroy multi-node

# To refresh all the cookbooks, use the following command.
$ CHEF_SERVER="$(terraform output chef_zero)" chef exec rake knife_upload
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `username/add_component_x`)
3. Write tests for your change
4. Write your change
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

- Author:: Oregon State University <chef@osuosl.org>

```text
Copyright:: 2017-2019 Oregon State University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
