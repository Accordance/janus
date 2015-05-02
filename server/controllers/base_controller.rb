class BaseController < Sinatra::Application
  configure do
    enable :logging
    enable :raise_errors
    enable :dump_errors
    enable :show_exceptions

    root_path = File.expand_path('../..', File.dirname(__FILE__))
    set :root, root_path
    set :static, true
  end

  before do
    logger.datetime_format = '%Y/%m/%d @ %H:%M:%S '
    logger.level           = Logger::INFO

    logger.info "root path: #{settings.root}"
  end
end
