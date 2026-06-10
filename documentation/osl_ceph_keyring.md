# `osl_ceph_keyring`

[Back to resource list](../README.md#resources)

Manages a Ceph keyring file from a known key, for example one stored in a data bag. Unlike
[`osl_ceph_client`](osl_ceph_client.md), this resource does not talk to the cluster — it only writes the
file.

Also available under the backwards-compatible name `ceph_keyring`.

## Actions

| Action    | Description              |
| --------- | ------------------------ |
| `:create` | Creates the keyring file |
| `:delete` | Removes the keyring file |

## Properties

| Name           | Type     | Default                              | Description                                |
| -------------- | -------- | ------------------------------------ | ------------------------------------------ |
| `key`          | `String` | Required for `:create`               | The Ceph key (sensitive)                   |
| `key_name`     | `String` | `client.<name>`                      | Entity name written inside the keyring     |
| `key_filename` | `String` | `ceph.client.<name>.keyring`         | Filename of the keyring                    |
| `owner`        | `String` | `ceph`                               | File owner                                 |
| `group`        | `String` | `ceph`                               | File group                                 |
| `mode`         | `String` | `0640`                               | File mode                                  |
| `ceph_dir`     | `String` | `/etc/ceph`                          | Directory the keyring is created in        |

## Examples

Create `/etc/ceph/ceph.client.admin.keyring` for `client.admin`:

```ruby
osl_ceph_keyring 'admin' do
  key 'AQBNzhVkbCJDOhAAhpqQqLR9G4y8VBXkCMSWiA=='
end
```

Create a bootstrap-osd keyring from a data bag:

```ruby
secrets = data_bag_item('ceph', 'cluster')

osl_ceph_keyring 'bootstrap-osd' do
  key secrets['bootstrap_key']
end
```
