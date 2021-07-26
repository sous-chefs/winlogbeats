cookbook_file 'C:/ProgramData/winlogbeat/winlogbeat.yml' do
  source 'filebeats.yml'
  owner 'Administrator'
  group 'Administrators'
  mode '0755'
  action :create
end

winlogbeats_agent '7.13.4'

# directory 'C:/ProgramData/winlogbeat' do
#   owner 'Administrator'
#   group 'Administrators'
#   recursive true
# enddirectory 'C:/ProgramData/winlogbeat' do
#   owner 'Administrator'
#   group 'Administrators'
#   recursive true
# end
