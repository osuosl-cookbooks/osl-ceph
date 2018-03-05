if defined?(ChefSpec)
  ChefSpec.define_matcher :ceph_chef_client
  def add_ceph_chef_client(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ceph_chef_client, :add, resource_name)
  end
end
