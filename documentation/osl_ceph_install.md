# `osl_ceph_install`

[Back to resource list](../README.md#resources)

Installs Ceph packages and configures the upstream (or OSUOSL-mirrored) yum repositories. On ppc64le and
AlmaLinux 8 nodes the OSUOSL repository mirror is used, otherwise packages come directly from
`download.ceph.com`. If any of the daemon properties are enabled, the firewall is opened for Ceph traffic
via `osl_firewall_ceph`.

## Actions

| Action     | Description                                       |
| ---------- | ------------------------------------------------- |
| `:install` | Configures the Ceph repos and installs packages   |

## Properties

| Name      | Type            | Default  | Description                                  |
| --------- | --------------- | -------- | -------------------------------------------- |
| `release` | `String`        | `reef`   | Ceph release to install                      |
| `mds`     | `true`, `false` | `false`  | Install the `ceph-mds` package               |
| `mgr`     | `true`, `false` | `false`  | Install the `ceph-mgr` and dashboard packages|
| `mon`     | `true`, `false` | `false`  | Install the `ceph-mon` package               |
| `osd`     | `true`, `false` | `false`  | Install the `ceph-osd` package               |
| `radosgw` | `true`, `false` | `false`  | Install the `ceph-radosgw` package           |

The `ceph-common` and `ceph-selinux` packages are always installed.

## Examples

Install the Ceph client packages only:

```ruby
osl_ceph_install 'default'
```

Install everything needed for a monitor + OSD node:

```ruby
osl_ceph_install 'default' do
  mon true
  osd true
end
```
