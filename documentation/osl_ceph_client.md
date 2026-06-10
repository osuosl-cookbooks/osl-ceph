# `osl_ceph_client`

[Back to resource list](../README.md#resources)

Creates a Ceph client auth entity on the cluster (if it does not already exist) and writes its keyring or
secret file. This resource runs `ceph auth` commands, so it must run on a node with admin access to a
working cluster.

Also available under the backwards-compatible name `ceph_chef_client`.

## Actions

| Action | Description                                                |
| ------ | ---------------------------------------------------------- |
| `:add` | Creates the auth entity and writes the keyring/secret file |

## Properties

| Name         | Type              | Default                                        | Description                                                       |
| ------------ | ----------------- | ---------------------------------------------- | ----------------------------------------------------------------- |
| `as_keyring` | `true`, `false`   | `true`                                         | Write a keyring file; if `false`, write only the bare key (secret)|
| `caps`       | `Hash`            | `{ 'mon' => 'allow r', 'osd' => 'allow r' }`   | Capabilities granted when creating the entity                     |
| `filename`   | `String`          | `/etc/ceph/ceph.client.<name>.<hostname>.keyring` (or `.secret`) | Destination file                                |
| `keyname`    | `String`          | `client.<name>.<hostname>`                     | Auth entity name                                                  |
| `key`        | `String`          | Fetched from the cluster                       | Use this key instead of generating/fetching one (sensitive)       |
| `owner`      | `String`          | `ceph`                                         | File owner                                                        |
| `group`      | `String`          | `ceph`                                         | File group                                                        |
| `mode`       | `Integer`, `String` | `0640`                                       | File mode                                                         |

## Examples

Create a read-only client for the local node:

```ruby
osl_ceph_client 'glance'
```

Create a client with custom caps and write it as a bare secret file:

```ruby
osl_ceph_client 'cinder' do
  caps('mon' => 'allow r', 'osd' => 'allow rwx pool=cinder')
  as_keyring false
  filename '/etc/ceph/ceph.client.cinder.secret'
end
```
