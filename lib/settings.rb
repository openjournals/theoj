
Settings = ActiveSupport::OrderedOptions.new

begin
  yaml = File.join(ENV['HOME'], '.rails.settings.yml')
  if File.exist?(yaml)
    require "erb"
    all_settings = YAML.load(ERB.new(IO.read(yaml)).result) || {}
    env_settings = all_settings[Rails.env]
    Settings.deep_merge!(env_settings.deep_symbolize_keys) if env_settings
  end

  yaml = File.join(Rails.root, 'config', 'settings.yml')
  if File.exist?(yaml)
    require "erb"
    all_settings = YAML.load(ERB.new(IO.read(yaml)).result) || {}
    env_settings = all_settings[Rails.env]
    Settings.deep_merge!(env_settings.deep_symbolize_keys) if env_settings
  end

  Settings.deep_merge!(Rails.application.secrets)
end