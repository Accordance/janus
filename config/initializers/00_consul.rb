require 'diplomat'
require 'yaml'

def init_consul_token(token_path)
  token = ENV['CONSUL_TOKEN'] || token_path
  return false if token.nil?

  token = File.read(token) if File.exist?(token)
  token = token.strip

  fail 'Invalid format of the token' unless uuid_validat?(token)
  ConsulToken.token = token
  true
end

def uuid_validat?(uuid)
  return true if uuid =~ /\A[\da-f]{32}\z/i
  return true if
    uuid =~ /\A(urn:uuid:)?[\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12}\z/i
end

class ConsulToken < Faraday::Middleware
  def self.token=(token)
    @@token = token
  end

  def call(env)
    query_params = env[:url].query || ''
    q = query_params.split('&')
    q << "token=#{@@token}"
    env[:url].query = q.join('&')
    @app.call(env)
    # @app.call(env).on_complete do |env|
    #   # do something with the response
    #   # env[:response] is now filled in
    #   puts env[:status]
    # end
  end
end

# class Custom404Errors < Faraday::Response::Middleware
#   def on_complete(env)
#     case env[:status]
#       when 404
#         raise RuntimeError, 'Custom 404 response'
#     end
#   end
# end

class ConsulLogger < Faraday::Middleware
  def call(env)
    # APP_LOGGER.debug "Consul URI access: #{env[:url]}"
    puts "Consul URI access: #{env[:url]}"
    @app.call(env)
    # @app.call(env).on_complete do |env|
    #   # do something with the response
    #   # env[:response] is now filled in
    #   puts env[:status]
    # end
  end
end

Diplomat.configure do |config|
  # TODO: simplify this
  path = 'config/config.yml'
  path = File.join(File.dirname(__FILE__), '..', 'config.yml') unless File.exist?(path)
  raw_config = File.read(path)

  config_data = YAML.load(raw_config)[RACK_ENV][:diplomat]

  fail "Can't find Diplomat configuration" if config_data.nil?

  config.url = ENV['CONSUL_URI'] || config_data[:consul_uri]

  middleware = [
    # Custom404Errors,
    # Faraday::Adapter::NetHttp
    # Faraday::Response::Logger
  ]

  middleware.unshift(ConsulToken) if init_consul_token(config_data[:consul_token])
  middleware.unshift(ConsulLogger) if ENV['LOG_LEVEL'] == 'DEBUG'
  config.middleware = middleware
end
