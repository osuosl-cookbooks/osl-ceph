name             'osl-ceph'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 12.18' if respond_to?(:chef_version)
issues_url       'https://github.com/osuosl-cookbooks/osl-ceph/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-ceph'
description      'Installs/Configures osl-ceph'
long_description 'Installs/Configures osl-ceph'
version          '2.1.1'

depends          'ceph-chef', '~> 1.1.27'
depends          'firewall'
depends          'git'
depends          'osl-nrpe'
depends          'systemd', '< 3.0.0'

supports         'centos', '~> 7.0'
