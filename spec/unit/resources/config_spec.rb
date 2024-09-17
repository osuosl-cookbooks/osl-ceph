require_relative '../../spec_helper'

describe 'osl_ceph_config' do
  platform 'almalinux', '8'
  cached(:subject) { chef_run }
  step_into :osl_ceph_config

  recipe do
    osl_ceph_config 'default' do
      fsid 'e981973a-b299-45c6-a827-db03dd848a8c'
      mon_initial_members %w(node1)
      mon_host %w(192.168.1.100)
      public_network %w(192.168.1.0/24)
      cluster_network %w(192.168.1.0/24)
    end
  end

  it do
    is_expected.to create_directory('/etc/ceph').with(
      owner: 'ceph',
      group: 'ceph',
      mode: '0750'
    )
  end

  it do
    is_expected.to create_template('/etc/ceph/ceph.conf').with(
      owner: 'ceph',
      group: 'ceph',
      variables: {
          cluster_network: '192.168.1.0/24',
          client_options: [
            'admin socket = /var/run/ceph/$cluster-$type.$id.asok',
          ],
          fsid: 'e981973a-b299-45c6-a827-db03dd848a8c',
          mon_host: '192.168.1.100',
          mon_initial_members: 'node1',
          public_network: '192.168.1.0/24',
          radosgw: false,
          rgw_dns_name: 'fauxhai.local',
      },
      cookbook: 'osl-ceph'
    )
  end

  it do
    is_expected.to render_file('/etc/ceph/ceph.conf').with_content(<<~EOF
       [global]
       auth client required = cephx
       auth cluster required = cephx
       auth service required = cephx
       cluster network = 192.168.1.0/24
       fsid = e981973a-b299-45c6-a827-db03dd848a8c
       keyring = /etc/ceph/$cluster.$name.keyring
       max open files = 131072
       mon host = 192.168.1.100
       mon initial members = node1
       mon pg warn max per osd = 0
       public network = 192.168.1.0/24

       [mon]
       keyring = /var/lib/ceph/mon/$cluster-$id/keyring

       [mds]
       keyring = /var/lib/ceph/mds/$cluster-$id/keyring
       mds cache size = 250000

       [osd]
       keyring = /var/lib/ceph/osd/$cluster-$id/keyring

       [client]
       admin socket = /var/run/ceph/$cluster-$type.$id.asok

       [client.admin]
       keyring = /etc/ceph/$cluster.client.admin.keyring
    EOF
                                                                  )
  end

  context 'multiple entries' do
    cached(:subject) { chef_run }

    recipe do
      osl_ceph_config 'default' do
        fsid 'e981973a-b299-45c6-a827-db03dd848a8c'
        mon_initial_members %w(node1 node2 node3)
        mon_host %w(192.168.1.100 192.168.1.101 192.168.1.102)
        public_network %w(192.168.1.0/24 192.168.2.0/24)
        cluster_network %w(192.168.1.0/24 192.168.2.0/24)
        client_options [
          'admin socket = /var/run/ceph/guests/$cluster-$type.$id.$pid.$cctid.asok',
        ]
      end
    end

    it do
      is_expected.to create_template('/etc/ceph/ceph.conf').with(
        owner: 'ceph',
        group: 'ceph',
        variables: {
            cluster_network: '192.168.1.0/24,192.168.2.0/24',
            client_options: [
              'admin socket = /var/run/ceph/guests/$cluster-$type.$id.$pid.$cctid.asok',
            ],
            fsid: 'e981973a-b299-45c6-a827-db03dd848a8c',
            mon_host: '192.168.1.100,192.168.1.101,192.168.1.102',
            mon_initial_members: 'node1,node2,node3',
            public_network: '192.168.1.0/24,192.168.2.0/24',
            radosgw: false,
            rgw_dns_name: 'fauxhai.local',
        },
        cookbook: 'osl-ceph'
      )
    end
    it do
      is_expected.to render_file('/etc/ceph/ceph.conf').with_content(<<~EOF
         [global]
         auth client required = cephx
         auth cluster required = cephx
         auth service required = cephx
         cluster network = 192.168.1.0/24,192.168.2.0/24
         fsid = e981973a-b299-45c6-a827-db03dd848a8c
         keyring = /etc/ceph/$cluster.$name.keyring
         max open files = 131072
         mon host = 192.168.1.100,192.168.1.101,192.168.1.102
         mon initial members = node1,node2,node3
         mon pg warn max per osd = 0
         public network = 192.168.1.0/24,192.168.2.0/24

         [mon]
         keyring = /var/lib/ceph/mon/$cluster-$id/keyring

         [mds]
         keyring = /var/lib/ceph/mds/$cluster-$id/keyring
         mds cache size = 250000

         [osd]
         keyring = /var/lib/ceph/osd/$cluster-$id/keyring

         [client]
         admin socket = /var/run/ceph/guests/$cluster-$type.$id.$pid.$cctid.asok

         [client.admin]
         keyring = /etc/ceph/$cluster.client.admin.keyring
      EOF
                                                                    )
    end
  end
end
