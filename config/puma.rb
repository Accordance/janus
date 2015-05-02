RACK_ENV = ENV['RACK_ENV'] || 'development'
puts "Puma environment detected: #{RACK_ENV}"

# Puma parameters: https://github.com/puma/puma/blob/master/examples/config.rb

root = "#{Dir.getwd}"

# if RACK_ENV == 'production'
#   bind "unix://#{root}/tmp/puma/socket"
#   pidfile "#{root}/tmp/puma/pid"
#   state_path "#{root}/tmp/puma/state"
# end
rackup "#{root}/config.ru"

# port ENV['PORT']
bind "tcp://0.0.0.0:#{ENV['PORT']}"
environment ENV['RACK_ENV']

threads 4, 8

activate_control_app
