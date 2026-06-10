# `osl_ceph_mgr`

[Back to resource list](../README.md#resources)

Sets up a Ceph manager daemon: creates the mgr keyring using `ceph auth get-or-create` and enables/starts
the `ceph-mgr@<hostname>` service. Requires a working monitor with admin access on the node.

## Actions

| Action     | Description                                |
| ---------- | ------------------------------------------ |
| `:start`   | Creates the mgr keyring, starts the service|
| `:restart` | Restarts the `ceph-mgr@<hostname>` service |

## Properties

None.

## Examples

```ruby
osl_ceph_mgr 'default' do
  subscribes :restart, 'osl_ceph_config[default]'
end
```
