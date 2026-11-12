# frozen_string_literal: true

require 'spec_helper'

describe 'winlogbeats_agent' do
  step_into :winlogbeats_agent
  platform 'windows', '2022'

  recipe do
    winlogbeats_agent 'agent'
  end

  it 'downloads the verified supported archive' do
    resource = chef_run.resource_collection.select { |item| item.resource_name == :remote_file }.first
    expect(resource.source).to eq ['https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-9.5.6-windows-x86_64.zip']
    expect(resource.checksum).to eq '48d0e5848a9d9acf48ed1071e68bbedb79d3e44fb9c387575bd4217008f65da9'
  end

  it 'extracts into Program Files and registers a properly quoted Windows service' do
    archive = chef_run.resource_collection.select { |item| item.resource_name == :archive_file }.first
    expect(archive.destination).to eq 'C:/Program Files/Winlogbeat'
    expect(archive.overwrite).to be true
    expect(chef_run).to create_windows_service('winlogbeat')
    expect(chef_run).to configure_windows_service('winlogbeat')
    command = chef_run.windows_service('winlogbeat').binary_path_name
    expect(command).to start_with('"C:\Program Files\Winlogbeat\winlogbeat-9.5.6-windows-x86_64\winlogbeat.exe" --environment=windows_service')
    expect(command).to include('-c "C:\Program Files\Winlogbeat\winlogbeat.yml"', '--path.data "C:\Program Files\Winlogbeat-Data"')
    expect(command).not_to include('`')
  end

  it 'leaves configuration ownership and starting explicit by default' do
    expect(chef_run).to create_directory('C:/Program Files/Winlogbeat')
      .with(owner: 'S-1-5-32-544', group: 'S-1-5-32-544')
    expect(chef_run).not_to create_file('C:/Program Files/Winlogbeat/winlogbeat.yml')
    expect(chef_run).not_to start_windows_service('start winlogbeat')
    expect(chef_run.windows_service('winlogbeat').startup_type).to eq :manual
  end

  context 'managed configuration and startup' do
    recipe do
      winlogbeats_agent 'configured agent' do
        configuration('winlogbeat.event_logs' => [{ 'name' => 'Application' }], 'output.file' => { 'path' => 'C:/events' })
        service_enabled true
      end
    end

    it 'writes sensitive YAML and enables and starts the configured service' do
      expect(chef_run).to create_file('C:/Program Files/Winlogbeat/winlogbeat.yml')
        .with(sensitive: true, content: /winlogbeat.event_logs:/)
      expect(chef_run).to enable_windows_service('start winlogbeat')
      expect(chef_run).to start_windows_service('start winlogbeat')
    end
  end

  %i(start stop).each do |verb|
    context verb.to_s do
      recipe do
        winlogbeats_agent 'agent' do
          action verb
        end
      end

      it 'controls the existing Windows service' do
        expect(chef_run).to public_send("#{verb}_windows_service", 'winlogbeat')
      end
    end
  end

  context 'removal' do
    recipe do
      winlogbeats_agent 'agent' do
        action :remove
      end
    end

    it 'stops and deletes the service, binaries, state and cached archive' do
      expect(chef_run).to stop_windows_service('winlogbeat')
      expect(chef_run).to delete_windows_service('winlogbeat')
      expect(chef_run).to delete_directory('C:/Program Files/Winlogbeat')
      expect(chef_run).to delete_directory('C:/Program Files/Winlogbeat-Data')
      archive = chef_run.resource_collection.select { |item| item.resource_name == :file && item.name.end_with?('.zip') }.first
      expect(archive.action).to eq [:delete]
    end
  end

  context 'retained event state' do
    recipe do
      winlogbeats_agent 'agent' do
        keep_data true
        action :remove
      end
    end

    it 'preserves state when explicitly requested' do
      expect(chef_run).not_to delete_directory('C:/Program Files/Winlogbeat-Data')
    end
  end

  context 'another version without a checksum' do
    recipe do
      winlogbeats_agent 'agent' do
        long_version 'winlogbeat-8.19.23-windows-x86_64'
      end
    end

    it 'rejects an unverified archive' do
      expect { chef_run }.to raise_error(ArgumentError, /Set checksum/)
    end
  end

  context 'a protected removal root' do
    recipe do
      winlogbeats_agent 'agent' do
        install_root 'C:/Program Files'
        action :remove
      end
    end

    it 'rejects a shared system root before removing anything' do
      expect { chef_run }.to raise_error(ArgumentError, /dedicated local directories/)
    end
  end

  context 'retained data inside the installation tree' do
    recipe do
      winlogbeats_agent 'agent' do
        data_dir 'C:/Program Files/Winlogbeat/data'
        keep_data true
        action :remove
      end
    end

    it 'rejects a retention request that recursive removal could not honour' do
      expect { chef_run }.to raise_error(ArgumentError, /outside install_root/)
    end
  end
end
