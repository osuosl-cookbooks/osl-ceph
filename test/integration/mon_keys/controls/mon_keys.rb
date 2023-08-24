control 'mon_keys' do
  describe command('ceph auth get mon.') do
    its('stdout') { should match(%r{AQBkf\+ZkFIMSLxAAnYRXnc/CaUdHChGCxyH3IQ==}) }
  end

  describe command('ceph auth get client.admin') do
    its('stdout') { should match(/AQBkf\+Zkw67WNBAAzK7M8SnedPLkYXIanbWNCg==/) }
  end

  describe command('ceph auth get client.bootstrap-osd') do
    its('stdout') { should match(/AQBkf\+Zk\+GsrOxAA1xYwZeLRB5gLI42lmjGV\+A==/) }
  end
end
