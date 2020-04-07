# Cookbook:: winlogbeats
# Resource:: logbeats_agent
#
# Copyright:: (C) 2016 Dan Webb
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

property :version, String, name_property: true
property :installer_url, String, default: lazy { "https://artifacts.elastic.co/downloads/beats/winlogbeat/#{long_version}.zip" }
property :logbeat_owner, String, default: lazy { 'Administrator' }
property :logbeat_group, String, default: lazy { 'Administrators' }
property :logbeat_config, String, default: lazy { 'C:/ProgramData/winlogbeat/winlogbeat.yml' }
property :long_version, String, default: lazy { 'winlogbeat-5.0.0-windows-x86_64' }

default_action :install

action :install do
  archive 'C:/ProgramData/winlogbeat' do
    source installer_url
    action :unzip
    not_if { ::File.exist?("C:/ProgramData/winlogbeat/#{long_version}") }
    notifies :restart, 'service[winlogbeat]', :delayed
  end

  powershell_script 'Install winlogbeat Windows Service' do
    code <<-EOH
    # delete service if it already exists
if (Get-Service winlogbeat -ErrorAction SilentlyContinue) {
  $service = Get-WmiObject -Class Win32_Service -Filter "name='winlogbeat'"
  $service.StopService()
  Start-Sleep -s 1
  $service.delete()
}

# create new service
New-Service -name winlogbeat `
  -displayName winlogbeat `
  -binaryPathName "`"C:\\ProgramData\\winlogbeat\\#{long_version}\\winlogbeat.exe`" -c `"#{logbeat_config}`""
EOH
    not_if 'Get-Service winlogbeat'
  end

  service 'winlogbeat' do
    supports restart: true,
             reload: false,
             status: true,
             stop: true,
             start: true
    action [:enable, :start]
  end
end
