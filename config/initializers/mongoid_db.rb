require 'mongoid'

module MongoDB
  def self.load_yaml(path, environment = nil)
    env = environment ? environment.to_s : RACK_ENV
    raw_config = File.new(path).read
    raw_yaml = YAML.load(raw_config)[env]
    template = ERB.new raw_yaml.to_yaml
    YAML.load(template.result(binding))
  end

  path = 'config/mongoid.yml'
  path = File.join(File.dirname(__FILE__), '..', 'mongoid.yml') unless File.exist?(path)
  settings = load_yaml(path, RACK_ENV)
  Mongoid.load_configuration(settings)

  Mongoid.logger = APP_LOGGER
  Moped.logger = APP_LOGGER

  I18n.enforce_available_locales = false
end
