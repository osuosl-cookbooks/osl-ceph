# `osl_ceph_config`

[Back to resource list](../README.md#resources)

Manages `/etc/ceph/ceph.conf`. Other service resources in this cookbook (`osl_ceph_mon`, `osl_ceph_mgr`,
etc.) can subscribe to this resource to restart their daemons when the configuration changes.

## Actions

| Action    | Description                  |
| --------- | ---------------------------- |
| `:create` | Creates `/etc/ceph/ceph.conf`|

## Properties

| Name                     | Type            | Default                                                | Description                                          |
| ------------------------ | --------------- | ------------------------------------------------------ | ---------------------------------------------------- |
| `fsid`                   | `String`        | Required                                               | Unique cluster identifier (UUID)                      |
| `mon_initial_members`    | `Array`         | Required                                               | Hostnames of the initial monitor nodes                |
| `mon_host`               | `Array`         | Required                                               | IP addresses of the monitor nodes                     |
| `public_network`         | `Array`         | Required                                               | Public network CIDR(s)                                |
| `cluster_network`        | `Array`         | Required                                               | Cluster (replication) network CIDR(s)                 |
| `client_options`         | `Array`         | `['admin socket = /var/run/ceph/$cluster-$type.$id.asok']` | Extra lines for the `[client]` section            |
| `radosgw`                | `true`, `false` | `false`                                                | Add a `[client.rgw.<hostname>]` section               |
| `rgw_dns_name`           | `String`        | `node['fqdn']`                                         | `rgw dns name` for the RadosGW section                |
| `rgw_dns_s3website_name` | `String`        | `<hostname>-website.<domain>`                          | `rgw dns s3website name` for the RadosGW section      |

## Examples

```ruby
osl_ceph_config 'default' do
  fsid 'ae3f1d03-bacd-4a90-b869-1a4fabb107f2'
  mon_initial_members %w(node1 node2 node3)
  mon_host %w(10.0.0.1 10.0.0.2 10.0.0.3)
  public_network %w(10.0.0.0/24)
  cluster_network %w(10.1.0.0/24)
end
```

With RadosGW enabled:

```ruby
osl_ceph_config 'default' do
  fsid 'ae3f1d03-bacd-4a90-b869-1a4fabb107f2'
  mon_initial_members %w(node1)
  mon_host %w(10.0.0.1)
  public_network %w(10.0.0.0/24)
  cluster_network %w(10.0.0.0/24)
  radosgw true
  rgw_dns_name 'rgw.example.org'
end
```
