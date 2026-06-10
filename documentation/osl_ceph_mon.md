# `osl_ceph_mon`

[Back to resource list](../README.md#resources)

Bootstraps a Ceph monitor: creates the mon, admin and bootstrap-osd keyrings, optionally generates a
monitor map, runs `ceph-mon --mkfs` and enables/starts the `ceph-mon@<hostname>` service. Keys can either
be generated on the fly (useful for testing) or passed in explicitly (e.g. from a data bag) so every
monitor in the cluster shares the same keys.

Requires `/etc/ceph/ceph.conf` to be in place first (see [`osl_ceph_config`](osl_ceph_config.md)).

## Actions

| Action     | Description                                  |
| ---------- | -------------------------------------------- |
| `:start`   | Bootstraps the monitor and starts the service|
| `:restart` | Restarts the `ceph-mon@<hostname>` service   |

## Properties

| Name              | Type            | Default              | Description                                                          |
| ----------------- | --------------- | -------------------- | -------------------------------------------------------------------- |
| `mon_key`         | `String`        | Generated            | `mon.` key (sensitive)                                               |
| `admin_key`       | `String`        | Generated            | `client.admin` key (sensitive)                                       |
| `bootstrap_key`   | `String`        | Generated            | `client.bootstrap-osd` key (sensitive)                               |
| `generate_monmap` | `true`, `false` | `true`               | Generate a monmap locally; set to `false` when joining an existing cluster |
| `ipaddress`       | `String`        | `node['ipaddress']`  | IP address used when generating the monmap                           |

## Examples

Bootstrap a standalone monitor with generated keys (testing):

```ruby
osl_ceph_mon 'default' do
  subscribes :restart, 'osl_ceph_config[default]'
end
```

Production monitor using shared keys from a data bag:

```ruby
secrets = data_bag_item('ceph', 'cluster')

osl_ceph_mon 'default' do
  mon_key secrets['mon_key']
  admin_key secrets['admin_key']
  bootstrap_key secrets['bootstrap_key']
  generate_monmap false
  subscribes :restart, 'osl_ceph_config[default]'
end
```
