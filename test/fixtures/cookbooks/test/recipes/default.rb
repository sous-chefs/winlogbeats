winlogbeats_agent '7.13.4'

cookbook_file 'C:/ProgramData/winlogbeat/winlogbeat.yml' do
  source 'filebeats.yml'
  owner 'Administrator'
  group 'Administrators'
  mode '0755'
  action :create
  notifies :restart, 'windows_service[winlogbeats]', :immediately
end
