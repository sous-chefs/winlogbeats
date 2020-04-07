# winlogbeats

WinLogBeats

This cookbook:

- Installs the WinLogBeats Agent
- Reads the config file on disk to configure the client. An example can be found in `recipes/default.rb`

It does not:

- Configure the agent

## Requirements

### Chef

- Chef 15+

## Platform

- Windows

## Resources

- [winlogbeats_agent](https://github.com/damacus/chef-winlogbeats/blob/master/documentation/resources/winlogbeats_agent.md)
