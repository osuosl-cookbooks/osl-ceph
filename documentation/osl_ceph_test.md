# `osl_ceph_test`

[Back to resource list](../README.md#resources)

Stands up a complete single-node Ceph cluster for **testing only**. It wraps
[`osl_ceph_install`](osl_ceph_install.md), [`osl_ceph_config`](osl_ceph_config.md),
[`osl_ceph_mon`](osl_ceph_mon.md) and [`osl_ceph_mgr`](osl_ceph_mgr.md), adjusts the CRUSH map so a single
node reports healthy, and creates three file-backed loopback OSDs. It can optionally create a CephFS
filesystem (with MDS) and a RadosGW.

Do not use this resource in production.

## Actions

| Action   | Description                            |
| -------- | -------------------------------------- |
| `:start` | Converges the single-node test cluster |

## Properties

| Name            | Type            | Default             | Description                                                       |
| --------------- | --------------- | ------------------- | ----------------------------------------------------------------- |
| `cephfs`        | `true`, `false` | `false`             | Also deploy an MDS and create a CephFS filesystem                  |
| `radosgw`       | `true`, `false` | `false`             | Also deploy a RadosGW                                              |
| `config`        | `Hash`          | None                | Settings passed to `osl_ceph_config` (fsid, mon_host, ...); a built-in test config is used when omitted |
| `create_config` | `true`, `false` | `true`              | Set to `false` to skip creating `ceph.conf` entirely               |
| `ipaddress`     | `String`        | `node['ipaddress']` | IP address for the monitor                                         |
| `osd_size`      | `String`        | `1G`                | Size of each of the three file-backed OSDs                         |

## Examples

```ruby
osl_ceph_test 'default'
```

With CephFS and larger OSDs:

```ruby
osl_ceph_test 'default' do
  cephfs true
  osd_size '4G'
end
```
