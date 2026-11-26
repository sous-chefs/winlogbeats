# Testing winlogbeats

Run `chef install Policyfile.rb`, `chef exec rspec` and `cookstyle` locally.
The resource specs step into install, start, stop and removal actions, including
configuration ownership, correctly quoted paths, checksums and state retention.

The default Kitchen suite runs the native Windows service with a local file
output, validates its configuration and version, then verifies an unchanged
second converge. The removal suite installs and removes the service and checks
its owned binaries and state are absent. Hosted CI runs both suites on actual
Windows Server 2022 and 2025 runners; local Vagrant uses Windows 2019/2022.

No test needs a live Elasticsearch backend or sends events externally.
