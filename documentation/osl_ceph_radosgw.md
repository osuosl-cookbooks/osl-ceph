# `osl_ceph_radosgw`

[Back to resource list](../README.md#resources)

Sets up a Ceph object gateway (RadosGW): opens port 8080 in the firewall, creates the rgw keyring via
`ceph auth add` and enables/starts the `ceph-radosgw@rgw.<hostname>` service. Requires a working monitor
with admin access on the node and a `[client.rgw.<hostname>]` section in `ceph.conf` (see the `radosgw`
property on [`osl_ceph_config`](osl_ceph_config.md)).

## Actions

| Action     | Description                                        |
| ---------- | -------------------------------------------------- |
| `:start`   | Creates the rgw keyring and starts the service     |
| `:restart` | Restarts the `ceph-radosgw@rgw.<hostname>` service |

## Properties

None.

## Examples

```ruby
osl_ceph_radosgw 'default' do
  subscribes :restart, 'osl_ceph_config[default]'
end
```
