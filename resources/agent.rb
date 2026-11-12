# frozen_string_literal: true

unified_mode true
provides :winlogbeats_agent

property :version, String, default: '9.5.6'
property :long_version, String, default: lazy { "winlogbeat-#{version}-windows-x86_64" }
property :installer_url, String, default: lazy { "https://artifacts.elastic.co/downloads/beats/winlogbeat/#{long_version}.zip" }
property :checksum, String, default: lazy {
  raise ArgumentError, 'Set checksum when using another Winlogbeat version' unless long_version == 'winlogbeat-9.5.6-windows-x86_64'

  '48d0e5848a9d9acf48ed1071e68bbedb79d3e44fb9c387575bd4217008f65da9'
}
property :owner, String, default: 'S-1-5-32-544'
property :group, String, default: 'S-1-5-32-544'
property :install_root, String, default: 'C:/Program Files/Winlogbeat'
property :data_dir, String, default: 'C:/Program Files/Winlogbeat-Data'
property :config_file, String, default: lazy { "#{install_root}/winlogbeat.yml" }
property :configuration, Hash, sensitive: true
property :service_enabled, [true, false], default: false
property :keep_data, [true, false], default: false

action :install do
  remote_file archive_path do
    source new_resource.installer_url
    checksum new_resource.checksum
  end

  [new_resource.install_root, new_resource.data_dir, ::File.dirname(new_resource.config_file)].uniq.each do |path|
    directory path do
      owner new_resource.owner
      group new_resource.group
      recursive true
    end
  end

  archive_file archive_path do
    destination new_resource.install_root
    not_if { ::File.exist?(executable_path) }
    notifies :restart, 'windows_service[winlogbeat]', :delayed if new_resource.service_enabled
  end

  if new_resource.configuration
    file new_resource.config_file do
      content YAML.dump(new_resource.configuration)
      owner new_resource.owner
      group new_resource.group
      sensitive true
      notifies :restart, 'windows_service[winlogbeat]', :delayed if new_resource.service_enabled
    end
  end

  windows_service 'winlogbeat' do
    binary_path_name service_command
    startup_type new_resource.service_enabled ? :automatic : :manual
    delayed_start new_resource.service_enabled
    action [:create, :configure]
    notifies :restart, 'windows_service[winlogbeat]', :delayed if new_resource.service_enabled
  end

  if new_resource.service_enabled
    windows_service 'start winlogbeat' do
      service_name 'winlogbeat'
      action [:enable, :start]
    end
  end
end

action :start do
  windows_service 'winlogbeat' do
    action [:enable, :start]
  end
end

action :stop do
  windows_service 'winlogbeat' do
    action :stop
  end
end

action :remove do
  windows_service 'winlogbeat' do
    action [:stop, :delete]
  end

  file new_resource.config_file do
    action :delete
    only_if { new_resource.configuration }
  end

  directory new_resource.install_root do
    recursive true
    action :delete
  end

  unless new_resource.keep_data
    directory new_resource.data_dir do
      recursive true
      action :delete
    end
  end

  file archive_path do
    action :delete
  end
end

action_class do
  def archive_path
    ::File.join(Chef::Config[:file_cache_path], "#{new_resource.long_version}.zip")
  end

  def executable_path
    "#{new_resource.install_root}/#{new_resource.long_version}/winlogbeat.exe"
  end

  def quoted_path(path)
    raise ArgumentError, 'Windows paths cannot contain quotes or newlines' if path.match?(/["\r\n]/)

    "\"#{path.tr('/', '\\')}\""
  end

  def service_command
    "#{quoted_path(executable_path)} --environment=windows_service -c #{quoted_path(new_resource.config_file)} " \
      "--path.home #{quoted_path("#{new_resource.install_root}/#{new_resource.long_version}")} " \
      "--path.data #{quoted_path(new_resource.data_dir)} --path.logs #{quoted_path("#{new_resource.data_dir}/logs")} " \
      '-E logging.files.redirect_stderr=true'
  end
end
