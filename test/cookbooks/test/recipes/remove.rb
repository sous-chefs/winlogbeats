# frozen_string_literal: true

include_recipe 'test::default'

winlogbeats_agent 'remove agent' do
  action :remove
end
