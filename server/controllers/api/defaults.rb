require 'grape'
# More examples can be found here: http://codetunes.com/2014/introduction-to-building-apis-with-grape/

module API
  module Defaults
    extend ActiveSupport::Concern # use Module#included hook

    included do
      format :json
      default_format :json

      # global exception handler, used for error notifications
      rescue_from :all do |e|
        fail e
      end

      helpers do
        # def current_user
        #   @current_user ||= User.authorize!(env)
        # end
        #
        # def authenticate!
        #   error!('401 Unauthorized', 401) unless current_user
        # end

        def logger
          APP_LOGGER
        end
      end

      # HTTP header based authentication
      # before do
      #   error!('Unauthorized', 401) unless headers['Authorization'] == "some token"
      # end
    end
  end
end
