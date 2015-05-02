#\ -s puma
RACK_ENV = ENV['RACK_ENV'] || 'development'

puts "Environment detected: #{RACK_ENV}"

require_relative 'lib/version'

require 'sinatra/base'
require 'rack/reloader'
require 'rack/contrib'
require 'sinatra'
require 'sidekiq/web'

Dir[File.dirname(__FILE__) + '/config/initializers/*.rb'].sort.each { |file| require file }

# Load all application files.
Dir["#{File.dirname(__FILE__)}/server/controllers/**/*.rb"].each { |file| require file }

configure do
  set :server, :puma
end

configure :development do |config|
  puts 'Development configuration'

  root_path      = File.dirname(__FILE__)
  set :root, root_path
  $public_folder = File.expand_path('../helios/dist', root_path)
  set :public_folder, $public_folder
  set :static, true
end

configure :production do
  puts 'Production configuration'

  # TODO: route all this to the APP_LOGGER

  # ENV['rack.errors'] = 'log/rack.log'
  # puts "Log routed to #{ENV['rack.errors']}"

  # log = File.new(ENV['rack.errors'], 'w')
  # use Rack::CommonLogger, log
  # $stdout.reopen(log)
  # $stderr.reopen(log)
  # $stderr.sync = true
  # $stdout.sync = true
end

# use Rack::Reloader

use Rack::ShowExceptions

use Rack::CommonLogger, APP_LOGGER

require 'rack/cors'
use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [ :get, :post, :put, :delete, :options ]
  end
end

map = Rack::URLMap.new({
                         '/sidekiq' => Sidekiq::Web
                       })

# require_relative 'server/controllers/home_controller'

# use Rack::Session::Cookie

handlers = [API::Root, map]

if RACK_ENV == 'development'
  files = Rack::File.new($public_folder)
  handlers = handlers.unshift(files)
  handlers << HomeController
end

run Rack::Cascade.new handlers
