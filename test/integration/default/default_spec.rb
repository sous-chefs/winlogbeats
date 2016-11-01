
describe file('C:\ProgramData\winlogbeat\winlogbeat-5.0.0-windows-x86_64\winlogbeat.exe') do
  it { should exist }
end

describe file('C:\ProgramData\winlogbeat\winlogbeat.yml') do
  it { should exist }
end

describe service('winlogbeat') do
  it { should be_running }
end
