# agent


## Properties

| Name          | Type   | Default                                                                       | Description                                                                  | Allowed Values |
| ------------- | ------ | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | -------------- |
| installer_url | String | `https://artifacts.elastic.co/downloads/beats/winlogbeat/<long_version}>.zip` | URL to download the winlogbeat zip from                                      |                |
| owner         | String | Administrator                                                                 | Owner of the winlogbeat directory                                            |                |
| group         | String | 'Administrators                                                               | Group for the winlogbeat directory                                           |                |
| config_file   | String | C:/ProgramData/winlogbeat/winlogbeat.yml                                      | Location of the yaml config file                                             |                |
| long_version  | String | winlogbeat-7.6.2-windows-x86_64                                               | long versio number for the zip file. Change to update the downloaded version |                |


## Example

Simple default installation

```ruby
winlogbeats_agent 'default'
```
