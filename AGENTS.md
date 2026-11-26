# winlogbeats contributor notes

## Confirmed scope

Full custom-resource migration and a supported Winlogbeat major, replacing the
pending patch release with a major release. There are no root recipes or
attributes. Preserve public intent and non-EOL Windows support. Land a feature
PR to main before Release Please generates the major release.

## Primary research

On 2026-11-12 Elastic's official GitHub latest release is v9.5.6, published
2026-11-02. The official x64 ZIP was downloaded, verified against its published
SHA-512, and SHA-256 was derived for Chef. Inspect the archive's vendor service
script when changing service flags; it uses --environment=windows_service and
explicit home/data/log paths. The vendor script can move or overwrite existing
ProgramData content, so this resource manages the service natively and leaves
legacy state migration explicit.

- [Official release](https://github.com/elastic/beats/releases/tag/v9.5.6)
- [Elastic support matrix](https://www.elastic.co/support/matrix)
- [Elastic installation script](https://www.elastic.co/docs/reference/beats/winlogbeat/winlogbeat-installation-script)
- [Elastic installation/configuration](https://www.elastic.co/docs/reference/beats/winlogbeat/winlogbeat-installation-configuration)

## Verification

Use Policyfile resolution, action-level step_into tests, Cookstyle, Markdown and
YAML lint, and InSpec profile checks. Native Windows 2022/2025 exec CI verifies
the real service is enabled/running, binary version, test config command, quoted
service command and complete removal. Install converges twice with idempotency;
removal deliberately runs a lifecycle in one converge. Tests write only to a
local file output and do not send event data to an external backend.

Do not run the retired cloud/AWS setup or provision paid infrastructure. Local
x64 Windows Vagrant guests cannot run on this Mac ARM host; use native CI.
