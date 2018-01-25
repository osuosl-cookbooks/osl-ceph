describe command('ceph osd stat') do
  its('stdout') { should match(/^3 osds: 3 up, 3 in$/) }
end

describe command('ss -tpln') do
  its('stdout') { should include 'ceph-osd' }
end

%w(
  ceph-osd.target
  ceph-osd@0.service
  ceph-osd@1.service
  ceph-osd@2.service
).each do |s|
  describe service(s) do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
