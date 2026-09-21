# `osl_ceph_exporter`

[Back to resource list](../README.md#resources)

Enables and starts the `ceph-exporter` service, which exposes Ceph daemon performance counters to
Prometheus on port `9926`. The package itself comes from `osl_ceph_install` with `exporter true`, which
also opens `9926` through `osl_firewall_ceph`; this resource only manages the daemon.

Reef stopped exporting daemon perf counters through the `mgr/prometheus` module: `exclude_perf_counters`
now defaults to `true` and the counters moved to this daemon. Without it, roughly half of every upstream
Ceph Grafana dashboard is empty, including everything built on `ceph_osd_stat_bytes`, `ceph_osd_op_*` and
`ceph_rgw_*`.

The RPM ships a plain `ceph-exporter.service`, not the instantiated `ceph-exporter@<id>.service` that
cephadm builds, but its `ExecStart` still carries `--id %i`. In a non-template unit that expands to an
empty client name, so the daemon looks for `/etc/ceph/ceph.client..keyring`, fails to authenticate, and
exits 1 on `failed to fetch mon config`. A `no-mon-config` drop-in replaces `ExecStart` to drop `--id` and
add `--no-mon-config`.

That means it needs no keyring, unlike every other Ceph daemon resource here: the counters come from the
local admin sockets in `/var/run/ceph`, and the mon round-trip only ever fetched config. The trade-off is
that `ceph config set exporter ...` is no longer read, so the port, socket directory and priority limit
come from `ceph.conf` or from the drop-in instead. Giving it a real `client.ceph-exporter` keyring the way
cephadm does (`mon`/`mgr`/`osd allow r`) would restore that, at the cost of a new entry in the `ceph` data
bag for the OSD-only nodes that have no admin keyring.

The exporter reports only counters at priority `PRIO_USEFUL` (5) or above, which is its default and covers
everything the upstream dashboards query.

## Actions

| Action     | Description                                                     |
| ---------- | --------------------------------------------------------------- |
| `:start`   | Enables and starts the service (default)                          |
| `:restart` | Restarts the `ceph-exporter` service                              |

## Properties

None.

## Examples

```ruby
osl_ceph_install 'exporter' do
  exporter true
end

osl_ceph_exporter 'default'
```
