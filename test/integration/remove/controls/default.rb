# frozen_string_literal: true

control 'removed-winlogbeat' do
  impact 1.0
  title 'Remove the service and every owned installation and state file'
  desc 'Verify the native service, versioned binaries, managed configuration and event state are absent.'

  describe service('winlogbeat') do
    it { should_not be_installed }
  end

  %w(Winlogbeat Winlogbeat-Data).each do |directory_name|
    describe directory("C:/Program Files/#{directory_name}") do
      it { should_not exist }
    end
  end
end
