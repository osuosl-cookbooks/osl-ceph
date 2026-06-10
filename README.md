# osl-ceph Cookbook

Installs and configures [Ceph](https://ceph.io/) nodes and clients at the OSU Open Source Lab. It manages
the Ceph yum repositories, packages, `ceph.conf`, daemon bootstrapping (mon, mgr, mds, osd, radosgw),
keyrings, CephFS mounts, RBD mappings and Nagios/NRPE monitoring.

## Requirements

### Platforms

- AlmaLinux 8, 9
- Ceph Reef release (default, configurable via `osl_ceph_install`)

### Chef

- Chef 16.0+

### Cookbooks

- `line`
- `osl-git`
- `osl-firewall`
- `osl-nrpe`
- `osl-repos`
- `osl-resources`

## Attributes

| Attribute                                                | Default                          | Description                                                              |
| -------------------------------------------------------- | -------------------------------- | ------------------------------------------------------------------------ |
| `node['osl-ceph']['config']`                              | `{}`                             | Cluster settings passed to `osl_ceph_config` by the default recipe (`fsid`, `mon_initial_members`, `mon_host`, `public_network`, `cluster_network`, optionally `client_options`, `radosgw`, `rgw_dns_name`, `rgw_dns_s3website_name`). No config is created when empty. |
| `node['osl-ceph']['data_bag_item']`                       | `nil`                            | Item in the `ceph` data bag containing `mon_key`, `admin_key` and `bootstrap_key`, used by the `mon` and `osd` recipes |
| `node['osl-ceph']['nrpe']['check_ceph_osd']['critical']`  | `1`                              | Critical threshold for the `check_ceph_osd` Nagios check                 |

## Recipes

| Recipe        | Description                                                                                       |
| ------------- | ------------------------------------------------------------------------------------------------- |
| `default`     | Installs the Ceph client packages and creates `ceph.conf` from `node['osl-ceph']['config']`        |
| `mds`         | Deploys a metadata server (CephFS)                                                                 |
| `mgr`         | Deploys a manager daemon                                                                           |
| `mon`         | Deploys a monitor using keys from the `ceph` data bag                                              |
| `osd`         | Deploys an OSD node, including a partprobe workaround for NVMe logical volumes                     |
| `radosgw`     | Deploys a RadosGW object gateway                                                                   |
| `nagios`      | Installs the [ceph-nagios-plugins](https://github.com/osuosl/ceph-nagios-plugins) checks           |
| `monitoring`  | Configures NRPE checks (`check_ceph_osd`, `check_ceph_mon`) using the `ceph/nagios` data bag item  |

## Resources

| Resource                                                | Description                                              |
| ------------------------------------------------------- | -------------------------------------------------------- |
| [osl\_ceph\_install](documentation/osl_ceph_install.md) | Configures Ceph yum repos and installs packages           |
| [osl\_ceph\_config](documentation/osl_ceph_config.md)   | Manages `/etc/ceph/ceph.conf`                             |
| [osl\_ceph\_mon](documentation/osl_ceph_mon.md)         | Bootstraps and runs a Ceph monitor                        |
| [osl\_ceph\_mgr](documentation/osl_ceph_mgr.md)         | Sets up and runs a Ceph manager                           |
| [osl\_ceph\_mds](documentation/osl_ceph_mds.md)         | Sets up and runs a Ceph metadata server                   |
| [osl\_ceph\_radosgw](documentation/osl_ceph_radosgw.md) | Sets up and runs a Ceph object gateway                    |
| [osl\_ceph\_keyring](documentation/osl_ceph_keyring.md) | Writes a keyring file from a known key                    |
| [osl\_ceph\_client](documentation/osl_ceph_client.md)   | Creates a client auth entity and its keyring/secret file  |
| [osl\_cephfs](documentation/osl_cephfs.md)              | Mounts a CephFS filesystem                                |
| [osl\_ceph\_rbdmap](documentation/osl_ceph_rbdmap.md)   | Manages RBD image mappings in `/etc/ceph/rbdmap`          |
| [osl\_ceph\_test](documentation/osl_ceph_test.md)       | Single-node test cluster (testing only)                   |

`osl_ceph_keyring` and `osl_ceph_client` are also available under their backwards-compatible names
`ceph_keyring` and `ceph_chef_client`.

## Testing

See [TESTING.md](TESTING.md) for unit, single-node and multi-node (kitchen-terraform) testing
instructions.

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
Copyright:: 2017-2026 Oregon State University

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
