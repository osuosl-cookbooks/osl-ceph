# `osl_ceph_rbdmap`

[Back to resource list](../README.md#resources)

Manages RBD image mappings in `/etc/ceph/rbdmap` and enables the `rbdmap` service so images are mapped at
boot. The keyring for the given `id` is expected at `/etc/ceph/ceph.client.<id>.keyring` (see
[`osl_ceph_keyring`](osl_ceph_keyring.md)).

## Actions

| Action    | Description                                                  |
| --------- | ------------------------------------------------------------ |
| `:create` | Adds the mapping to `/etc/ceph/rbdmap` and enables the service|
| `:remove` | Removes the mapping from `/etc/ceph/rbdmap`                   |

## Properties

| Name      | Type     | Default                | Description                              |
| --------- | -------- | ---------------------- | ---------------------------------------- |
| `image`   | `String` | Name property          | RBD image name                           |
| `pool`    | `String` | Required               | Pool containing the image                |
| `id`      | `String` | Required for `:create` | Ceph client id used to map the image     |
| `options` | `String` | None                   | Extra options appended to the map entry  |

## Examples

Map `data/myimage` using `client.backup`:

```ruby
osl_ceph_rbdmap 'myimage' do
  pool 'data'
  id 'backup'
end
```

With extra options:

```ruby
osl_ceph_rbdmap 'myimage' do
  pool 'data'
  id 'backup'
  options 'lock_on_read,queue_depth=1024'
end
```
