name             'osl-ceph'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 16.0'
issues_url       'https://github.com/osuosl-cookbooks/osl-ceph/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-ceph'
description      'Installs/Configures osl-ceph'
version          '9.0.5'

depends          'line'
depends          'osl-git'
depends          'osl-firewall'
depends          'osl-nrpe'
depends          'osl-repos'
depends          'osl-resources'

supports         'almalinux', '~> 8.0'
supports         'almalinux', '~> 9.0'
