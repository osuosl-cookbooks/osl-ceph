osl-ceph CHANGELOG
==================
This file is used to list changes made in each version of the
osl-ceph cookbook.

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

