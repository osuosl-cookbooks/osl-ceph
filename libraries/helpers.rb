module OslCeph
  module Cookbook
    module Helpers
      include Chef::Mixin::ShellOut

      def ceph_osuosl_repo
        if node['kernel']['machine'] == 'ppc64le' || node['platform_version'].to_i == 8
          true
        else
          false
        end
      end

      def ceph_yum_baseurl
        if ceph_osuosl_repo
          "https://ftp.osuosl.org/pub/osl/repos/yum/$releasever/ceph-#{new_resource.release}/$basearch"
        else
          "https://download.ceph.com/rpm-#{new_resource.release}/el$releasever/$basearch"
        end
      end

      def ceph_yum_gpgkey
        if ceph_osuosl_repo
          'https://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl'
        else
          'https://download.ceph.com/keys/release.asc'
        end
      end

      def ceph_packages
        packages = %w(ceph-common ceph-selinux)
        packages.push('ceph-mds') if new_resource.mds

        if new_resource.mgr
          packages.push('ceph-mgr')
          packages.push('ceph-mgr-dashboard')
        end

        packages.push('ceph-mon') if new_resource.mon
        packages.push('ceph-osd') if new_resource.osd
        packages.push('ceph-radosgw') if new_resource.radosgw

        packages.sort
      end

      def ceph_auth_exists?(name)
        ceph_auth = Mixlib::ShellOut.new('ceph auth ls')
        ceph_auth.run_command
        ceph_auth.error!

        ceph_auth.stdout.match(/^#{name}$/)
      end

      def ceph_fsid
        begin
          File.read('/etc/ceph/ceph.conf')[/^fsid = (.*)/, 1]
        rescue
          if node['osl-ceph']['config'].empty?
            nil
          else
            node['osl-ceph']['config']['fsid']
          end
        end
      end

      def ceph_mon_addresses
        begin
          File.read('/etc/ceph/ceph.conf')[/^mon host = (.*)/, 1].split(',')
        rescue
          nil
        end
      end

      private

      def ceph_mgr_auth
        mgr_name = "mgr.#{node['hostname']}"

        ceph_auth = Mixlib::ShellOut.new(
          "ceph auth get-or-create #{mgr_name} mon 'allow profile mgr' osd 'allow *' mds 'allow *'"
        )
        ceph_auth.run_command
        ceph_auth.error!

        ceph_auth.stdout
      end

      def ceph_mount_opts
        "_netdev,name=#{new_resource.client_name},secretfile=/etc/ceph/ceph.client.#{new_resource.client_name}.secret"
      end

      def ceph_get_key(keyname)
        key = Mixlib::ShellOut.new("ceph auth print_key #{keyname}")
        key.run_command
        key.error!

        key.stdout
      end

      def ceph_keyname
        new_resource.keyname || "client.#{new_resource.name}.#{node['hostname']}"
      end

      def ceph_key
        new_resource.key || ceph_get_key(keyname)
      end

      def ceph_key_filename
        if new_resource.filename
          new_resource.filename
        else
          suffix = new_resource.as_keyring ? 'keyring' : 'secret'
          "/etc/ceph/ceph.client.#{new_resource.name}.#{node['hostname']}.#{suffix}"
        end
      end

      def ceph_file_content(keyname, key, as_keyring)
        if as_keyring
          "[#{keyname}]\n\tkey = #{key}\n"
        else
          key
        end
      end

      def ceph_create_entity(keyname)
        tmp_keyring = "#{Chef::Config[:file_cache_path]}/.#{keyname}.keyring"
        caps = new_resource.caps.map { |k, v| "#{k} '#{v}'" }.join(' ')

        if new_resource.key
          # store key provided in a temporary keyring file
          cmd = Mixlib::ShellOut.new(
            "ceph-authtool #{tmp_keyring} --create-keyring --name #{keyname} --add-key '#{new_resource.key}'"
          )
          cmd.run_command
          cmd.error!

          key_option = "-i #{tmp_keyring}"
        else
          key_option = ''
        end

        cmd = Mixlib::ShellOut.new("ceph auth #{key_option} add #{keyname} #{caps}")
        cmd.run_command
        cmd.error!

        # remove temporary keyring file
        file tmp_keyring do
          action :delete
          sensitive true
        end
      end
    end
  end
end
Chef::DSL::Recipe.include ::OslCeph::Cookbook::Helpers
Chef::Resource.include ::OslCeph::Cookbook::Helpers
