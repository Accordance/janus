require 'newrelic_rpm'

if ENV['RACK_ENV'] == 'development'
  puts 'Loading NewRelic in developer mode ...'
  require 'new_relic/rack/developer_mode'
  use NewRelic::Rack::DeveloperMode
else
  newrelic_env = ENV['RACK_ENV']
  config = YAML.load(ERB.new(File.dirname(__FILE__), '..', 'newrelic.yml').result)
  ENV['NEW_RELIC_LICENSE_KEY'] = config[newrelic_env]['license_key']
  NewRelic::Control.instance.env = newrelic_env
  NewRelic::Agent.manual_start env: newrelic_env
end
