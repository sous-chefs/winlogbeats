# winlogbeats cookbook

Install and manage Winlogbeat 9.5.6 on supported x64 Windows with the
`winlogbeats_agent` custom resource. Requires Chef Infra Client 16 or later.

```ruby
winlogbeats_agent 'agent' do
  configuration(
    'winlogbeat.event_logs' => [{ 'name' => 'Application' }],
    'output.elasticsearch' => { 'hosts' => ['https://elastic.example:9200'] }
  )
  service_enabled true
end
```

Supply the authentication and TLS settings required by your Elasticsearch
deployment through your secret store. The resource can also use a configuration
file managed by your wrapper cookbook. Installation alone registers a manual
service; set `service_enabled true` or use `:start` to run it.

See the [resource reference](documentation/resources/winlogbeats_agent.md),
[migration guide](documentation/migration.md) and [testing guide](TESTING.md).

## Licence

Apache-2.0. Original cookbook by Dan Webb; maintained by Sous Chefs.
The downloaded Winlogbeat distribution has its own Elastic licence.
