control 'admin_tools' do
  %w(ceph-assess ceph-metrics-assess ceph-check-rotational).each do |tool|
    describe file("/usr/local/sbin/#{tool}") do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its('mode') { should cmp '0750' }
    end
  end

  # Run in the osd suite (mon, mgr and three hdd OSDs); /root is unreadable to the kitchen user, so read the log by path.
  assess = command('/usr/local/sbin/ceph-assess')
  log = assess.stdout[%r{^Saved to: (/root/ceph-assess-node1-\d{8}T\d{4}Z\.log)}, 1]

  describe assess do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(%r{^Saved to: /root/ceph-assess-node1-}) }
  end

  describe file(log.to_s) do
    it { should be_file }
    its('content') { should match(/^===== ceph versions =====$/) }
    its('content') { should match(/^===== ceph osd df tree class hdd =====$/) }
    its('content') { should match(/^===== fullest hdd OSD: osd\.\d+ - PGs on it \(top 40\) =====$/) }
    its('content') { should match(/^===== machine-readable osd df \(json\) =====\n\n?\{"nodes":/) }
    its('content') { should_not match(/device class list failed/) }
  end

  describe command('/usr/local/sbin/ceph-check-rotational') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/of 3 OSD\(s\) flagged/) }
  end

  describe command('/usr/local/sbin/ceph-metrics-assess') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(%r{^Saved to: /root/ceph-metrics-assess-node1-}) }
  end
end
