firewall = input('firewall')

control 'default' do
  %w(ceph-common ceph-selinux).each do |p|
    describe package p do
      it { should be_installed }
      its('version') { should cmp < '18.0.0' }
    end
  end

  describe command('ceph --version') do
    its('exit_status') { should eq 0 }
    its('stdout') { should include 'quincy' }
  end

  describe yum.repo('ceph') do
    it { should exist }
    it { should be_enabled }
  end

  describe yum.repo('ceph-noarch') do
    it { should exist }
    it { should be_enabled }
  end

  describe iptables do
    if firewall
      it { should have_rule('-N ceph') }
    else
      it { should_not have_rule('-N ceph') }
    end
  end
end
