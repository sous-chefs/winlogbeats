unified_mode true

property :installer_url,
        String,
        default: lazy { "https://artifacts.elastic.co/downloads/beats/winlogbeat/#{long_version}.zip" },
        description: 'URL to download the winlogbeat zip from'

property :owner,
        String,
        default: 'Administrator',
        description: 'Owner of the winlogbeat directory'

property :group,
        String,
        default: 'Administrators',
        description: 'Group for the winlogbeat directory'

property :install_directory,
        String,
        default: 'C:/Program Files/winlogbeat',
        description: 'Directory to install all files to'

property :config_file,
        String,
        default: 'winlogbeat.yml',
        description: 'Location of the yaml config file'

property :long_version,
        String,
        default: 'winlogbeat-7.6.2-windows-x86_64',
        description: 'long versio number for the zip file. Change to update the downloaded version'

action :install do
  remote_file "#{Chef::Config[:file_cache_path]}/#{new_resource.long_version}.zip" do
    source new_resource.installer_url
    mode '644'
  end

  directory new_resource.install_directory do
    owner new_resource.owner
    group new_resource.group
    recursive true
  end

  archive_file "#{Chef::Config[:file_cache_path]}/#{new_resource.long_version}.zip" do
    destination new_resource.install_directory
    not_if { ::File.exist?(::File.join(new_resource.install_directory, new_resource.long_version)) }
    notifies :restart, 'windows_service[winlogbeat]', :delayed
  end

  install_path = ::File.join(new_resource.install_directory, new_resource.long_version, 'winlogbeat.exe')

  windows_service 'winlogbeat' do
    binary_path_name "`#{install_path}` -c `#{new_resource.config_file}`"
    supports restart: true, reload: false, status: true, stop: true, start: true
    action :create
  end
end
