# config/initializers/sidekiq.rb

require 'redis-sentinel'
require 'sidekiq'

SIDEKIQ_CONFIG = APP_CONFIG[:sidekiq]
if RACK_ENV == 'testing'
  require 'sidekiq/testing'
  Sidekiq::Testing.fake!
else
  fail 'No Sidekiq configuration was found' if SIDEKIQ_CONFIG.nil?

  if SIDEKIQ_CONFIG[:logger] == false
    Sidekiq::Logging.logger = nil
  else
    Sidekiq::Logging.logger = APP_LOGGER
  end

  Sidekiq.configure_client do |config|
    options = {}

    redis_url = APP_CONFIG[:sidekiq][:url].to_s
    if redis_url != ''
      options[:url] = redis_url
    else
      options[:master_name] = SIDEKIQ_CONFIG[:master_name]
      options[:sentinels] = Array(SIDEKIQ_CONFIG[:sentinels])
      options[:failover_reconnect_timeout] = SIDEKIQ_CONFIG[:failover_reconnect_timeout]
    end
    options[:size] = APP_CONFIG[:sidekiq][:size]

    config.redis = options
  end
end
