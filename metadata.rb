name             'osl-ceph'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'apachev2'
issues_url       'https://github.com/osuosl-cookbooks/osl-ceph/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-ceph'
description      'Installs/Configures osl-ceph'
long_description 'Installs/Configures osl-ceph'
version          '0.1.0'

depends          'ceph-chef', '~> 1.1.27'
depends          'firewall'

supports         'centos', '~> 7.0'
