# `osl_ceph_mds`

[Back to resource list](../README.md#resources)

Sets up a Ceph metadata server (MDS) for CephFS: creates the mds keyring via `ceph auth add` and
enables/starts the `ceph-mds@<hostname>` service. Requires a working monitor with admin access on the
node.

## Actions

| Action     | Description                                |
| ---------- | ------------------------------------------ |
| `:start`   | Creates the mds keyring, starts the service|
| `:restart` | Restarts the `ceph-mds@<hostname>` service |

## Properties

None.

## Examples

```ruby
osl_ceph_mds 'default' do
  subscribes :restart, 'osl_ceph_config[default]'
end
```
