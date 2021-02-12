name             'osl-ceph'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 14.0'
issues_url       'https://github.com/osuosl-cookbooks/osl-ceph/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-ceph'
description      'Installs/Configures osl-ceph'
version          '3.4.1'

depends          'ceph-chef', '~> 3.0.0'
depends          'firewall'
depends          'git'
depends          'osl-nrpe'
depends          'systemd'

supports         'centos', '~> 7.0'
