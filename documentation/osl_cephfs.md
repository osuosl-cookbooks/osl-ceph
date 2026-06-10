# `osl_cephfs`

[Back to resource list](../README.md#resources)

Mounts a CephFS filesystem. The resource name is the mount point. Writes the client secret to
`/etc/ceph/ceph.client.<client_name>.secret`, creates the mount point and manages the fstab entry and/or
mount. Monitor addresses are read from `mon host` in `/etc/ceph/ceph.conf`, so the node needs a Ceph
config in place (see [`osl_ceph_config`](osl_ceph_config.md)).

## Actions

| Action    | Description                                                  |
| --------- | ------------------------------------------------------------ |
| `:mount`  | Adds the fstab entry and mounts the filesystem               |
| `:enable` | Adds the fstab entry only                                    |
| `:umount` | Unmounts, removes the fstab entry and deletes the secret file|

## Properties

| Name          | Type     | Default                         | Description                                  |
| ------------- | -------- | ------------------------------- | -------------------------------------------- |
| `key`         | `String` | Required for `:enable`, `:mount`| Ceph client key (sensitive)                  |
| `client_name` | `String` | `admin`                         | Ceph client to authenticate as               |
| `subdir`      | `String` | `/`                             | CephFS sub-directory to mount                |
| `options`     | `String` | None                            | Extra mount options                          |

## Examples

Mount the root of CephFS on `/mnt/cephfs` as `client.admin`:

```ruby
osl_cephfs '/mnt/cephfs' do
  key 'AQBNzhVkbCJDOhAAhpqQqLR9G4y8VBXkCMSWiA=='
end
```

Mount a sub-directory with a dedicated client and read-only options:

```ruby
osl_cephfs '/mnt/projects' do
  key data_bag_item('ceph', 'cluster')['projects_key']
  client_name 'projects'
  subdir '/projects'
  options 'ro'
end
```
