describe command('ceph health') do
  its('stdout') { should match(/^HEALTH_OK$/) }
end

describe port('6789') do
  it { should be_listening }
  its('processes') { should include 'ceph-mon' }
end
