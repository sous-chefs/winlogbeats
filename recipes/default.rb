directory 'C:/ProgramData/winlogbeat' do
  owner 'Administrator'
  group 'Administrators'
  recursive true
end

cookbook_file 'C:/ProgramData/winlogbeat/winlogbeat.yml' do
  source 'filebeats.yml'
  owner 'Administrator'
  group 'Administrators'
  mode '0755'
  action :create
end

winlogbeats_agent '5' do
  logbeat_config 'C:/ProgramData/winlogbeat/winlogbeat.yml'
end
