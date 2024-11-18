osl-ceph CHANGELOG
==================
This file is used to list changes made in each version of the
osl-ceph cookbook.

9.0.0 (2024-11-18)
------------------
- Update to Quincy release

8.1.1 (2024-11-15)
------------------
- Fix idempotency issues in production

8.1.0 (2024-11-13)
------------------
- Add support for s3website and cname buckets

8.0.0 (2024-11-13)
------------------
- Update to Pacific release

7.0.1 (2024-10-29)
------------------
- Move edit_resource to default recipe

7.0.0 (2024-10-29)
------------------
- Update to Octopus release

6.5.3 (2024-10-23)
------------------
- Test Kitchen Config Refactor

6.5.2 (2024-10-11)
------------------
- Start partprobe on boot before Ceph

6.5.1 (2024-09-20)
------------------
- Add rgw_dns_name to default recipe

6.5.0 (2024-09-20)
------------------
- Allow setting of rgw_dns_name to a static name

6.4.0 (2024-09-17)
------------------
- Add radosgw support

6.3.0 (2024-07-05)
------------------
- Remove support for CentOS 7

6.2.1 (2024-04-09)
------------------
- Add bootstrap-osd keyring

6.2.0 (2024-03-22)
------------------
- Add osl_ceph_rbdmap resource

6.1.1 (2023-12-11)
------------------
- Also check for fsid in attributes

6.1.0 (2023-10-06)
------------------
- osl_ceph_test: add ipaddress parameter

6.0.1 (2023-09-07)
------------------
- Add mgr dashboard package

6.0.0 (2023-09-05)
------------------
- Update to Nautilus release

5.0.2 (2023-08-30)
------------------
- nagios: Set a branch to use for the ceph-nagios-plugins repository

5.0.1 (2023-08-30)
------------------
- Fix typo in parameter name in keyring resource

5.0.0 (2023-08-29)
------------------
- Major refactor into a resource driven cookbook

4.7.1 (2023-02-21)
------------------
- Move StartLimitBurst to Service

4.7.0 (2023-02-20)
------------------
- EPEL fixes

4.6.0 (2022-08-23)
------------------
- Replace base with osl-resources

4.5.0 (2022-02-16)
------------------
- Add options property to osl_cephfs resource

4.4.0 (2022-02-16)
------------------
- Add :enable action to osl_cephfs

4.3.0 (2021-07-15)
------------------
- Bump ceph-chef version

4.2.0 (2021-07-14)
------------------
- Use osl_systemd_unit_drop_in resource instead of systemd cookbook

4.1.0 (2021-06-16)
------------------
- Enable unified_mode on custom resource

4.0.0 (2021-05-25)
------------------
- Update to new osl-firewall resources

3.5.0 (2021-04-06)
------------------
- Update Chef dependency to >= 16

3.4.1 (2021-02-12)
------------------
- Implement workaround for mount bug in Chef

3.4.0 (2020-09-25)
------------------
- Update to chef 16

3.3.0 (2020-06-22)
------------------
- Chef 15 fixes

3.2.1 (2019-12-19)
------------------
- Chef 14 post-migration fixes

3.2.0 (2019-11-08)
------------------
- Update to using systemd_service_drop_in

3.1.0 (2019-10-10)
------------------
- Chef 14 Fixes

3.0.0 (2019-05-09)
------------------
- Update to Mimic release

2.2.1 (2019-03-26)
------------------
- Update baseurl for ppc64le repository

2.2.0 (2019-01-17)
------------------
- Create osl_cephfs custom resource

2.1.1 (2018-10-19)
------------------
- Switch to using filesystem based OSD for test-kitchen testing

2.1.0 (2018-09-21)
------------------
- Add MDS (metadata server) recipe

2.0.0 (2018-09-20)
------------------
- Chef 13 Fixes

1.3.3 (2018-06-11)
------------------
- Remove execute[change-ceph-conf-perm] resource in other recipes

1.3.2 (2018-06-11)
------------------
- Remove execute[change-ceph-conf-perm] resource

1.3.1 (2018-06-11)
------------------
- Improve nagios checks deployment

1.3.0 (2018-05-18)
------------------
- Implement ceph_keyring resource

1.2.0 (2018-05-16)
------------------
- Split nagios plugin installation into its own recipe

1.1.2 (2018-03-17)
------------------
- Don't assume the OSD node also is a mon node

1.1.1 (2018-03-06)
------------------
- Create per node nagios auth keys

1.1.0 (2018-03-05)
------------------
- Add nagios checks to ceph

1.0.0 (2018-02-19)
------------------
- Ceph Luminous 

0.1.0
-----
- Initial release of osl-ceph

