# frozen_string_literal: true

control 'running-winlogbeat' do
  impact 1.0
  title 'Run the supported Winlogbeat service with valid local configuration'
  desc 'Verify binary version, configuration validity and native service startup without an external backend.'

  describe service('winlogbeat') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  executable = 'C:/Program Files/Winlogbeat/winlogbeat-9.5.6-windows-x86_64/winlogbeat.exe'
  describe command("& '#{executable}' version") do
    its('exit_status') { should eq 0 }
    its('stdout') { should include '9.5.6' }
  end

  describe command("& '#{executable}' test config -c 'C:/Program Files/Winlogbeat/winlogbeat.yml' --path.data 'C:/Program Files/Winlogbeat-Data'") do
    its('exit_status') { should eq 0 }
    its('stdout') { should include 'Config OK' }
  end

  describe command('(Get-CimInstance Win32_Service -Filter "Name=\'winlogbeat\'").PathName') do
    its('stdout') { should include '--environment=windows_service', '--path.data', 'Winlogbeat-Data' }
    its('stdout') { should_not include '`' }
  end
end
