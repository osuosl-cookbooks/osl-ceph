# Working on osl-ceph

Notes for anyone, human or agent, changing this cookbook. The README and
`documentation/` describe how to *use* the `osl_ceph_*` resources; this
file covers how to *change* them without surprising the two production
clusters. Operating those clusters (capacity, health, rebalancing, RGW
buckets) is covered by the `ceph-ops` skill in the osl Claude plugin.

**Hard rules** (from osuosl-cookbooks' CLAUDE.md, restated for agents
that read only this file):
- plan before any edit;
- `cinc exec cookstyle` and `cinc exec rspec <spec>` only, never rake, gem, bundle or `chef exec` (TESTING.md still says `chef exec`; it is out of date);
- local branches and commits only; never push or open a PR unless the user says so;
- never create, converge or destroy kitchen instances;
- never read data bags or production secrets;
- never edit the `version` line in `metadata.rb` or `CHANGELOG.md`;
- code comments are at most two lines.

## Who runs it

| Cluster | Nodes | Roles | Release |
|---|---|---|---|
| fs (x86) | fs-mon1–3 (mon, mgr, mds, radosgw, `s3_admin`), fs1–fs17 (osd), AlmaLinux 9 | `ceph_x86` + `ceph_{mon,mgr,mds,radosgw,osd}_x86`, `ceph_radosgw_enable_x86` | Reef 18.2.8 from download.ceph.com |
| openpower (ppc64le) | op-ceph1–5 (mon, mgr, osd), AlmaLinux 8 | `ceph_ppc64` + `ceph_{mon,mgr,osd}_ppc64` | Reef 18.2.7 from the OSL repo on ftp.osuosl.org (`ceph_osuosl_repo`: any ppc64le or EL8 node) |
| clients | backup2, ftp-osl, jumphost, util2, the OpenStack nodes | `ceph_x86_client`, `ceph_ppc64_client` | |

- `ceph_x86` and `ceph_ppc64` carry `osl-ceph::monitoring`, so every Ceph host runs ceph-exporter and the NRPE checks.
- Both clusters are production storage for OpenStack. A converge that restarts OSDs or mons on many hosts at once is an outage risk, so say in the plan how existing nodes behave on their next converge.

## Ownership split

| Resource | Owns | Never |
|---|---|---|
| `osl_ceph_install` | the repos and **every package** (`ceph_packages` in `libraries/helpers.rb`, keyed on the daemon flags `exporter`, `mds`, `mgr`, `mon`, `osd`, `radosgw`), and the `osl_firewall_ceph` opening whenever a daemon flag is set | services |
| `osl_ceph_config` | `/etc/ceph/ceph.conf` from `templates/ceph.conf.erb` (fsid, mon hosts, networks, the `[client.rgw.<host>]` section) | packages |
| `osl_ceph_mon`, `_mgr`, `_mds`, `_radosgw`, `_exporter` | that daemon's keyring, unit, drop-ins and service (`osl_ceph_radosgw` also opens its own :8080) | packages |
| `osl_ceph_keyring`, `osl_ceph_client`, `osl_cephfs`, `osl_ceph_rbdmap` | client-side keys, mounts and maps | |

**A new daemon** gets a flag on `osl_ceph_install` plus its own resource for the service, as `exporter` did in 10.5.0 (PR #82). Do not install a package from a daemon resource.

## Things that have bitten

- **ceph-exporter's RPM unit is plain `ceph-exporter.service`, not a template.**
  - Its `ExecStart` passes `--id %i`, which expands to an empty id. The daemon then looks for `ceph.client..keyring` and exits with `failed to fetch mon config`.
  - `osl_ceph_exporter` replaces `ExecStart` in a drop-in with `-f --no-mon-config --setuser ceph --setgroup ceph`. As a result, `ceph config set exporter ...` is not read.
  - Giving it a real `client.ceph-exporter.<host>` keyring would need a new bag entry, because OSD-only hosts have no admin key.
- **`ceph-rotational.service`** (`files/ceph-rotational.rb`, installed by `recipes/osd.rb`) fixes the rotational flag for SSDs behind MegaRAID virtual drives.
  - It is a Cinc-Ruby script (`#!/opt/cinc/embedded/bin/ruby`) that uses `Chef::Mixin::ShellOut`. It **always exits 0**: a failed oneshot that Chef starts would abort every future converge.
  - Its ordering lives in drop-ins on the `ceph-osd@.service` and `ceph-volume@.service` **templates**, with `Wants` and `After`. `Before=ceph.target` orders nothing, because `ceph-volume@` starts OSDs at runtime.
- **ceph-exporter holds `client.admin`'s admin socket.**
  - Its drop-in passes no `--id`, so it runs as `client.admin`.
  - The default `[client] admin socket = /var/run/ceph/$cluster-$type.$id.asok` (`resources/config.rb`) then gives it `ceph-client.admin.asok`.
  - Every root `ceph` command on that host prints `AdminSocketConfigObs::init: failed ... (17) File exists` to stderr.
  - Fixed: the drop-in now passes `--admin-socket /var/run/ceph/ceph-exporter.asok`. Nodes still on the old drop-in show the line until they converge, so `ceph-assess` keeps filtering it.
- **`ConditionPathExists` on a unit Chef starts breaks idempotency.** When the condition is false, `is-active` says inactive, so Chef starts the unit on every run. Put the check inside the script instead.
- **The osd recipe's ordering units and the rotational fix restart nothing by themselves.** OSDs pick up a new rotational flag, and so their mclock capacity key, only when they restart. A rollout that needs a restart is a manual, host-by-host step with `noout` (ceph-ops `health.md`), written into the PR description; it is never recipe code.
- **A ceph.conf change restarts every daemon.** `recipes/{mon,mgr,mds,radosgw,osd}.rb` each `subscribes :restart, 'osl_ceph_config[default]'`. One template change, even an RGW-only key, restarts every mon, mgr, MDS, RGW and `ceph-osd.target` on every node within one converge window.
  - Such a PR states it in the description.
  - It rolls out with cinc-client paused and host-by-host converges under `noout` (ceph-ops `health.md`).
  - Prefer `ceph config set` for anything that is a runtime option.

## Operator tools

- `files/ceph-assess`, `files/ceph-metrics-assess` and `files/ceph-check-rotational` are installed into `/usr/local/sbin` on every mon by `recipes/admin_tools.rb`, which `mon` includes.
- They are the only copy. The ceph-ops skill tells operators to run them and parses their logs (`assess_report.py` reads the `===== <cmd> =====` banners and the `osd df` JSON section), so keep that format stable or change the skill in the same piece of work.
- Rules:
  - read-only on the cluster;
  - every command wrapped in `timeout`;
  - one log per run at `/root/<tool>-<host>-<UTC>.log`;
  - nothing that prints keys.
- Kitchen's `osd` suite runs all three (control `admin_tools` in `test/integration/mon/controls/`). The `mon` suite has no mgr, so `osd df` and `osd perf` would only time out there.

## Tests

- **ChefSpec:**
  - `spec/unit/recipes` and `spec/unit/resources` follow the usual layout.
  - Node-side scripts shipped under `files/` have their own specs in `spec/unit/files/` (`ceph_rotational_spec.rb`). That spec must `require 'spec_helper'` **before** loading the script, or the whole ChefSpec run breaks.
  - Its fixtures are real storcli captures (`spec/fixtures/storcli-*.json`), never hand-written JSON. Ask the user for a capture from the host if a new controller shape is needed.
  - To run the script under the node's Ruby without Workstation's gem path leaking in:
    ```
    env -u GEM_HOME -u GEM_PATH /opt/cinc/embedded/bin/ruby ...
    ```
- **Kitchen single node:**
  - `ceph_test` (`test/cookbooks/ceph_test`) builds a one-node cluster through `osl_ceph_test`.
  - The `monitoring` suite checks ceph-exporter on :9926 and its `/metrics`.
  - The kitchen mgr does **not** serve :9283, because its prometheus module is off.
  - Use `kitchen exec <full-instance> -c 'sudo ...'` for probes.
- **Kitchen multi-node:** `kitchen.multi-node.yml` with kitchen-terraform (`main.tf`, `test/integration/multi-node`) builds a real cluster on OpenStack. Hand it to the user for any change to mon, osd or keyring handling.

## Dependencies

- `osl-firewall` owns the Ceph ports: 6789, 3300, 6800–7300, 9283 for the mgr and 9926 for the exporter, all honouring `osl_only`.
- A new port goes through the three-state Berksfile chain:
  1. `path: '../osl-firewall'` while developing;
  2. `git:` plus `branch:` with a draft PR and a `Cookbook-Chain:` line;
  3. `depends 'osl-firewall', '>= X.Y.Z'` once it is released.

  That is what 10.5.0 did.
- `osl-nrpe` installs storcli (packages.osuosl.org; x86 at `/opt/MegaRAID/storcli/storcli64` with `/usr/local/sbin` links, ppc64le at `/usr/sbin/storcli`). The rotational script searches those paths.

## Secrets

- `ceph/<data_bag_item>` holds the mon, admin and bootstrap keys and the RGW admin S3 keys (`rgw_admin_access_key`, `rgw_admin_secret_key`).
- `ceph/nagios` holds the per-arch NRPE token.
- Specs stub both; kitchen uses `test/integration/data_bags/`. Never read the real items.

## Documentation to update with a change

- This cookbook's `README.md` and `documentation/osl_ceph_*.md`, one per resource.
- `~/git/osl/docs/source/software/ceph/`:
  - `ceph_cookbook.rst` (what the cookbook deploys);
  - `ceph_troubleshooting.rst`;
  - `ceph_s3.rst` (`s3_admin` and `create-s3-bucket`);
  - `ceph_osd.rst` and `ceph_maintenance.rst` (operator procedures).
- The ceph-ops skill's `references/` in osuosl/claude-plugins, when a change alters what operators see: ports, units, scripts, metric sources.
