if defined?(ChefSpec)
  def create_ceph_keyring(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ceph_keyring, :create, resource_name)
  end

  def delete_ceph_keyring(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ceph_keyring, :delete, resource_name)
  end
end
