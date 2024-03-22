control 'rbdmap' do
  describe file '/etc/ceph/rbdmap' do
    its('content') { should match %r{^pool/image id=image,keyring=/etc/ceph/ceph\.client\.image\.keyring$} }
  end

  describe service 'rbdmap' do
    it { should be_enabled }
  end
end
