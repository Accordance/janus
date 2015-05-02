require 'sinatra/base'

require_relative './base_controller.rb'

class HomeController < Sinatra::Base
  get '/' do
    if RACK_ENV == 'production'
      redirect '/sidekiq'
    else
      File.read(File.join($public_folder, 'index.html'))
    end
  end

  get '/api_doc' do
    File.read(File.join($public_folder, 'api.html'))
  end

  run! if __FILE__ == $0
end
