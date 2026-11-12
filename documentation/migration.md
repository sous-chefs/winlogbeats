# Migrating to winlogbeats 1.0

The owner selected a supported major Winlogbeat version. The default changes
from EOL 7.6.2 to 9.5.6. Confirm your Elasticsearch/Logstash compatibility and
update your event and output configuration before upgrading an existing host.
The cookbook is already resource-based; there are no root recipes or attributes
to retain. The public `winlogbeats_agent` name and existing source, owner, group,
configuration path and long archive name properties remain available.

Chef Infra Client 16 or later and supported x64 Windows are required. Windows
Server 2016, 2019, 2022 and 2025 are supported by the selected Elastic release.
The old Windows Server 2012 R2 cloud image is EOL and is replaced by local
Windows 2019/2022 VM suites and actual hosted Windows 2022/2025 CI runners.

Installations now live under `C:/Program Files/Winlogbeat`, configuration defaults
to that installation root, and event state defaults to
`C:/Program Files/Winlogbeat-Data`. This follows Elastic's move to the stricter
Program Files permissions. The resource does not move or delete an existing
ProgramData tree during installation. Stop the old service, migrate the event
state with your retention procedure, then set `data_dir` to its intended path
so events are not replayed unintentionally. Explicit old configuration paths
remain supported.

The previous service command used literal backticks instead of Windows quotes.
It also only created the service, leaving an existing binary path unchanged.
The resource now quotes paths, includes the Windows service environment and
updates the existing service configuration. Installation registers a manual
service by default; supply configuration and set `service_enabled true` to
enable and start it, or call `:start` explicitly. Configuration/archive changes
restart the managed service when automatic startup is selected.

Custom archive versions now require a checksum. The bundled obsolete example
configuration is replaced by the `configuration` property or a wrapper-managed
file. Removal deletes the service, owned binaries, archive and state; use
`keep_data true` to retain event state. External configuration is preserved.

The feature PR keeps the current cookbook metadata version. Release Please
should generate 1.0.0 after the breaking feature reaches main, replacing #33.
