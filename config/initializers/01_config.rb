require 'erb'
require 'yaml'

path = 'config/config.yml'
path = File.join(File.dirname(__FILE__), '..', 'config.yml') unless File.exist?(path)
raw_config = File.read(path)
raw_yaml = YAML.load(raw_config)[RACK_ENV]
template = ERB.new raw_yaml.to_yaml
APP_CONFIG = YAML.load(template.result(binding))
