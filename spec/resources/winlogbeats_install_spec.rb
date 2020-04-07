require 'spec_helper'

describe 'winlogbeats_agent' do
  step_into :winlogbeats_agent
  platform 'windows'
  context 'Install the Winlogbeats Agent' do
    recipe do
      winlogbeats_agent 'test'
    end

    it 'Creates the correct service ' do
      is_expected.to create_windows_service('winlogbeat')
    end
  end
end
