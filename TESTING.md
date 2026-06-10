# Testing

## Unit tests

```console
chef exec rspec
```

## Single-node integration tests

Standard Test Kitchen suites using Vagrant (see [kitchen.yml](kitchen.yml)) or OpenStack
(see [kitchen.openstack.yml](kitchen.openstack.yml)):

```console
kitchen test default-almalinux-9
```

Most suites use the `ceph_test` test cookbook ([test/cookbooks/ceph_test](test/cookbooks/ceph_test)),
which deploys a single-node cluster via the `osl_ceph_test` resource.

## Multi-node integration tests

This cookbook utilizes [kitchen-terraform](https://github.com/newcontext-oss/kitchen-terraform) to test
deploying various parts of this cookbook on multiple nodes, similar to that in production.

### Prereqs

- Chef Workstation
- Terraform
- `kitchen-terraform`
- OpenStack cluster

Ensure you have the following in your `.bashrc` (or similar):

```bash
export TF_VAR_ssh_key_name="$OS_SSH_KEYPAIR"
```

### Supported Deployments

- Chef-zero node acting as a Chef Server
- Three node ceph cluster
  - Each ceph node runs mon, mgr, mds and osd services
- One cephfs client node
  - The cephfs client node will mount cephfs from the ceph cluster

### Running the tests

First, generate some keys for chef-zero and then simply run the following suite.

```console
# Only need to run this once
$ chef exec rake create_key
$ kitchen test multi-node
```

Be patient as this will take a while to converge all of the nodes (approximately 15 minutes).

### Access the nodes

Unfortunately, kitchen-terraform doesn't support using `kitchen console` so you will need to log into the
nodes manually. To see what their IP addresses are, just run `terraform output` which will output all of
the IPs.

```bash
# You can run the following commands to login to each node
$ ssh almalinux@$(terraform output -raw node1)
$ ssh almalinux@$(terraform output -raw node2)
$ ssh almalinux@$(terraform output -raw node3)
$ ssh almalinux@$(terraform output -raw cephfs_client)

# Or you can look at the IPs for all of the nodes at once
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

### Running ceph commands

Once you're logged into one of the nodes, you should be able to run the following commands:

```bash
$ ceph -s
  cluster:
    id:     7964405e-3e4a-4aee-b5a8-bf5e4f816c5d
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node1,node3,node2
    mgr: node1(active), standbys: node2, node3
    mds: cephfs-1/1/1 up  {0=node2=up:active}, 2 up:standby
    osd: 9 osds: 9 up, 9 in

$ ceph osd tree
ID CLASS WEIGHT  TYPE NAME      STATUS REWEIGHT PRI-AFF
-1       0.08817 root default
-3       0.02939     host node1
 0   hdd 0.00980         osd.0      up  1.00000 1.00000
...
```

### Interacting with the chef-zero server

All of these nodes are configured using a Chef Server which is a container running chef-zero. You can
interact with the chef-zero server by doing the following:

```bash
$ CHEF_SERVER="$(terraform output -raw chef_zero)" knife node list -c test/chef-config/knife.rb
cephfs_client
node1
node2
node3
$ CHEF_SERVER="$(terraform output -raw chef_zero)" knife node edit -c test/chef-config/knife.rb
```

In addition, on any node that has been deployed, you can re-run `chef-client` like you normally would on a
production system. This should allow you to do development on your multi-node environment as needed.
**Just make sure you include the knife config otherwise you will be interacting with our production chef
server!**

### Using Terraform directly

You do not need to use kitchen-terraform directly if you're just doing development. It's primarily useful
for testing the multi-node cluster using inspec. You can simply deploy the cluster using terraform
directly by doing the following:

```bash
# Sanity check
$ terraform plan
# Deploy the cluster
$ terraform apply
# Destroy the cluster
$ terraform destroy
```

### Cleanup

```bash
# To remove all the nodes and start again, run the following test-kitchen command.
$ kitchen destroy multi-node

# To refresh all the cookbooks, use the following command.
$ CHEF_SERVER="$(terraform output -raw chef_zero)" chef exec rake knife_upload
```
