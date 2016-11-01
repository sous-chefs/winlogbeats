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
  service_enabled true
end
