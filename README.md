# chef-winlogbeats
WinLogBeats

This cookbook:
- Installs the WinLogBeats Agent
- Reads the config file on disk to configure the client. An example can be found in `recipes/default.rb`

It does not:
- Configure the agent

## Requirements
### Chef
- Chef 12.5+

## Platform
- Windows


## Custom Resource
```
winlogbeats_agent '5' do
  logbeat_config 'C:/ProgramData/winlogbeat/winlogbeat.yml'
end
```

Change the value of `logbeat_config` to the file you put on disk.


## Recipes
### default  
Installs the client & puts a default config on disk pointing to a local elasticsearch host 
