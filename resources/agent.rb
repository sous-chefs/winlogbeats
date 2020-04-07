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

property :installer_url, String, default: lazy { "https://artifacts.elastic.co/downloads/beats/winlogbeat/#{long_version}.zip" },
                                 description: 'URL to download the winlogbeat zip from'
property :owner, String, default: 'Administrator',
                         description: 'Owner of the winlogbeat directory'
property :group, String, default: 'Administrators',
                         description: 'Group for the winlogbeat directory'
property :config_file, String, default: 'C:/ProgramData/winlogbeat/winlogbeat.yml',
                               description: 'Location of the yaml config file'
property :long_version, String, default: 'winlogbeat-7.6.2-windows-x86_64',
                                description: 'long versio number for the zip file. Change to update the downloaded version'

action :install do
  remote_file "#{Chef::Config[:file_cache_path]}/#{new_resource.long_version}.zip" do
    source new_resource.installer_url
    mode '644'
  end

  directory 'C:/ProgramData/winlogbeat' do
    owner new_resource.owner
    group new_resource.group
    recursive true
  end

  archive_file "#{Chef::Config[:file_cache_path]}/#{new_resource.long_version}.zip" do
    destination 'C:/ProgramData/winlogbeat'
    not_if { ::File.exist?("C:/ProgramData/winlogbeat/#{new_resource.long_version}") }
    notifies :restart, 'windows_service[winlogbeat]', :delayed
  end

  install_path = "C:\\ProgramData\\winlogbeat\\#{new_resource.long_version}\\winlogbeat.exe"

  windows_service 'winlogbeat' do
    binary_path_name "`#{install_path}` -c `#{new_resource.config_file}`"
    supports restart: true, reload: false, status: true, stop: true, start: true
    action :create
  end
end
