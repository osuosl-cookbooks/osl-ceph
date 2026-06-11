# The s3_admin kitchen suite points the S3 endpoint at the local RGW
# (<fqdn>:8080, no https) so create-s3-bucket can be exercised end-to-end.
control 's3_admin' do
  fqdn = command('hostname -f').stdout.strip
  describe package('s3cmd') do
    it { should be_installed }
  end

  describe file('/root/.s3cfg') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0600' }
    its('content') { should match(/^access_key = TESTACCESSKEY$/) }
    its('content') { should match(/^secret_key = TESTSECRETKEY$/) }
    its('content') { should match(/^host_base = #{Regexp.escape(fqdn)}:8080$/) }
    its('content') { should match(/^host_bucket = #{Regexp.escape(fqdn)}:8080$/) }
    its('content') { should match(/^use_https = False$/) }
  end

  describe file('/usr/local/sbin/create-s3-bucket') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0750' }
  end

  describe command('/usr/local/sbin/create-s3-bucket') do
    its('exit_status') { should eq 2 }
    its('stderr') { should match(/^Usage:/) }
  end

  describe command('/usr/local/sbin/create-s3-bucket foo_bad backups') do
    its('exit_status') { should eq 1 }
    its('stderr') { should match(/must be lowercase alphanumeric/) }
  end

  describe command('/usr/local/sbin/create-s3-bucket fooproject backups') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Bucket 'fooproject-backups' is owned by 'fooproject'/) }
    its('stdout') { should match(/"access_key"/) }
    its('stdout') { should match(/"secret_key"/) }
    its('stdout') { should match(/Secrets app/) }
  end

  # Re-running must be safe and leave ownership intact
  describe command('/usr/local/sbin/create-s3-bucket fooproject backups && echo RERUN_OK') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/already exists \(owner: fooproject\)/) }
    its('stdout') { should match(/RERUN_OK/) }
  end

  describe command('radosgw-admin bucket stats --bucket=fooproject-backups') do
    its('stdout') { should match(/"owner":\s*"fooproject"/) }
  end
end
