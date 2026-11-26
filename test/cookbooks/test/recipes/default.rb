# frozen_string_literal: true

winlogbeats_agent 'agent' do
  configuration('winlogbeat.event_logs' => [{ 'name' => 'Application' }], 'output.file' => { 'path' => 'C:/Program Files/Winlogbeat-Data/output', 'filename' => 'events' })
  service_enabled true
end
