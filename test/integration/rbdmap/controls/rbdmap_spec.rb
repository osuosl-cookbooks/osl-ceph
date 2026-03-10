control 'rbdmap' do
  describe file '/etc/ceph/rbdmap' do
    its('content') { should match %r{^pool/image id=image,keyring=/etc/ceph/ceph\.client\.image\.keyring$} }
    its('content') { should match %r{^pool/image_with_options id=image,keyring=/etc/ceph/ceph\.client\.image\.keyring,options=queue_depth=64$} }
  end

  describe service 'rbdmap' do
    it { should be_enabled }
  end
end
