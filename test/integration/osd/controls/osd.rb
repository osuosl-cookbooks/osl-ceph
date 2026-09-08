control 'osd' do
  describe command('ceph osd stat') do
    its('stdout') { should match(/^3 osds: 3 up.*, 3 in/) }
  end

  describe command('ss -tpln') do
    its('stdout') { should include 'ceph-osd' }
  end

  describe file '/usr/local/libexec/partprobe.sh' do
    it { should be_executable }
  end

  describe service 'partprobe.service' do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe file '/usr/local/libexec/ceph-rotational.rb' do
    it { should be_executable }
    its('mode') { should cmp '0750' }
    its('owner') { should eq 'root' }
  end

  # RemainAfterExit keeps a successful oneshot active; anything else here means
  # the fixer failed, which would also make the Chef run non-idempotent.
  describe service 'ceph-rotational.service' do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  # No MegaRAID controller in a VM, so it must no-op cleanly rather than fail.
  describe command('/usr/local/libexec/ceph-rotational.rb') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/megaraid_sas not loaded/) }
  end

  %w(ceph-osd ceph-volume).each do |unit|
    describe file "/etc/systemd/system/#{unit}@.service.d/rotational.conf" do
      it { should exist }
      its('content') { should match(/Wants\s*=\s*ceph-rotational\.service/) }
      its('content') { should match(/After\s*=\s*ceph-rotational\.service/) }
    end
  end

  # The drop-in has to reach the template's instances, not just the template.
  describe command('systemctl show -p After ceph-osd@0.service') do
    its('stdout') { should match(/ceph-rotational\.service/) }
  end

  describe service('ceph-osd.target') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
