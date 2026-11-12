# winlogbeats_agent

Install a verified Winlogbeat archive and configure its native Windows service.

## Actions

- `:install` (default): download and extract binaries, create owned directories,
  optionally write configuration, and create or update the Windows service.
- `:start`: enable and start the existing service.
- `:stop`: stop the existing service.
- `:remove`: stop and delete the service, remove the installation tree, cached
  archive and owned event state. `keep_data true` preserves event state. An
  externally managed configuration outside the installation tree is preserved.

## Properties

| Property | Type | Default | Meaning |
| --- | --- | --- | --- |
| `version` | String | `9.5.6` | Version used to construct the default archive name. |
| `long_version` | String | `winlogbeat-9.5.6-windows-x86_64` | Retained archive name override. |
| `installer_url` | String | Elastic artifacts URL for long_version | Archive source. |
| `checksum` | String | Verified 9.5.6 SHA-256 | Required explicitly for other versions. |
| `owner` | String | `Administrator` | Owner for managed directories and configuration. |
| `group` | String | `Administrators` | Group for managed directories and configuration. |
| `install_root` | String | `C:/Program Files/Winlogbeat` | Dedicated installation tree, including the versioned directory. |
| `data_dir` | String | `C:/Program Files/Winlogbeat-Data` | Dedicated event state and logs directory. |
| `config_file` | String | `<install_root>/winlogbeat.yml` | Configuration file passed to the service. |
| `configuration` | Hash | nil | If supplied, write sensitive YAML. Otherwise the wrapper manages the file. |
| `service_enabled` | Boolean | false | Install with automatic delayed startup, enable and start the service. Otherwise register it for manual startup. |
| `keep_data` | Boolean | false | Preserve the data directory during removal. |

The Windows service name is `winlogbeat`. Use a single resource configuration
per host; the resource name labels the operation rather than creating an
independent service instance. The executable, configuration, home, state and log
paths are quoted correctly for Windows service command-line parsing.

```ruby
winlogbeats_agent 'register externally configured agent' do
  config_file 'C:/Managed Configuration/winlogbeat.yml'
end

winlogbeats_agent 'remove agent' do
  keep_data true
  action :remove
end
```

Use matching path properties on installation and removal. Do not point the
installation or data properties at shared directories: removal owns those trees.
Shared parents of an external configuration file are not removed.
