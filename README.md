# osl-ceph Cookbook

OSL wrapper cookbook for upstream [ceph-chef cookbooks](https://github.com/ceph/ceph-chef/). Also includes support for
ppc64le compute nodes.

## Supported Platforms

- Ceph Luminous Release
- CentOS 7

# Multi-host test integration

This cookbook utilizes [Chef Provisioning](https://github.com/chef/chef-provisioning) to test deploying various parts
of this cookbook in multiple nodes, similar to that in production.

## Prereqs

- ChefDK 1.2.20
- OpenStack cluster

### Openstack Provisioning

This uses the [Chef Provisioning Fog provider](https://github.com/chef/chef-provisioning-fog) and requires a bit of
extra setup:

``` console
$ chef gem install chef-provisioning-fog
```

Next you need to create a ``~/.fog`` file which contains the various bits of information (replace with your
credentials):

``` yaml
default:
    openstack_api_key: <OS_PASSWORD>
    openstack_auth_url: https://openstack.example.org:5000/v2.0/tokens
    openstack_tenant: admin
    openstack_username: admin
    private_key_path: /home/manatee/.ssh/id_rsa
    public_key_path: /home/manatee/.ssh/id_rsa.pub
```

Next you need to set the following environment variables:

``` bash
NODE_OS=        # UUID of CentOS 7 image
FLAVOR=         # UUID of flavor for m1.large
CHEF_DRIVER=fog:OpenStack

# Various OpenStack variables
OS_SSH_KEYPAIR=       # Name of ssh key on OpenStack to use
OS_NETWORK_UUID=			# UUID of the network to use
```

## Initial Setup Steps

``` console
$ git clone https://github.com/osuosl-cookbooks/osl-ceph.git
$ cd osl-ceph
$ chef exec rake berks_vendor
```
## Supported Deployments

- Three node ceph cluster
	- Each node runs mon, mgr and osd services

## Rake Deploy Commands

These commands will spin up various compute nodes.

``` bash
# Spin up three node ceph cluster
$ chef exec rake ceph
# Spin up only node1
$ chef exec rake node1
# Spin up only node2
$ chef exec rake node2
# Spin up only node3
$ chef exec rake node3
```

## Access the nodes

If you get an error about more than one server exists, just run ``openstack server list`` and find the UUID of the
server you created.

``` bash
# node1
$ openstack server show -c addresses -f value node1
private=192.168.56.X, 140.211.168.X
$ ssh centos@140.211.168.X
# node2
$ openstack server show -c addresses -f value node2
private=192.168.56.X, 140.211.168.X
$ ssh centos@140.211.168.X
# node3
$ openstack server show -c addresses -f value node3
private=192.168.56.X, 140.211.168.X
$ ssh centos@140.211.168.X
```

## Running ceph commands

Once you're logged into one of the nodes, you should be able to run the following commands:

``` bash
$ ceph -s
  cluster:
    id:     b82e53b3-595b-4ee4-833a-56a714ea5c76
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node3,node2,node1
    mgr: node1(active), standbys: node2, node3
    osd: 9 osds: 9 up, 9 in

  data:
    pools:   4 pools, 512 pgs
    objects: 45 objects, 95157 kB
    usage:   14162 MB used, 27270 MB / 41432 MB avail
    pgs:     512 active+clean

$ ceph osd tree
ID CLASS WEIGHT  TYPE NAME      STATUS REWEIGHT PRI-AFF
-1       0.03955 root default
-3       0.01318     host node1
 0   hdd 0.00439         osd.0      up  1.00000 1.00000
 1   hdd 0.00439         osd.1      up  1.00000 1.00000
 2   hdd 0.00439         osd.2      up  1.00000 1.00000
-5       0.01318     host node2
 3   hdd 0.00439         osd.3      up  1.00000 1.00000
 4   hdd 0.00439         osd.4      up  1.00000 1.00000
 5   hdd 0.00439         osd.5      up  1.00000 1.00000
-7       0.01318     host node3
 6   hdd 0.00439         osd.6      up  1.00000 1.00000
 7   hdd 0.00439         osd.7      up  1.00000 1.00000
 8   hdd 0.00439         osd.8      up  1.00000 1.00000
```

## Cleanup

``` bash
# To remove all the nodes and start again, run the following rake command.
$ chef exec rake destroy_machines

# To refresh all the cookbooks, use the following command.
$ chef exec rake berks_vendor

# To cleanup everything, including the cookbooks and machines run the following command.
$ chef exec rake clean
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `username/add_component_x`)
3. Write tests for your change
4. Write your change
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

##License and Authors

- Author:: Oregon State University <chef@osuosl.org>

```text
Copyright:: 2017, Oregon State University

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
