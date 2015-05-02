require 'grape'
require 'grape-entity'

require_relative 'api/defaults'
require_relative 'build_messages_controller'

# curl -k -v -X POST -d "message={ \"app\": [\"test1,test2\"], \"artifact_version\": \"v0.1.2\", \
# \"env\": \"f1\", \"action\": \"deploy\", \"status_url\" : \"http://buildserver.accordance.net/jenkins/job/deploy-app/206/api/json\", \
# \"status\": \"finished\", \"server\": \"server01\", \"mc\": \"false\" }" http://localhost:8081/queues/build-messages
# curl -k -v -X POST -d "message={ \"env\": \"f1\" }" http://localhost:8081/queues/boostrap-app

module API
  class QueuesController < Grape::API
    include API::Defaults

    helpers do
      # def current_user
      #   @current_user ||= User.authorize!(env)
      # end
      #
      # def authenticate!
      #   error!('401 Unauthorized', 401) unless current_user
      # end
    end

    namespace :queues do
      mount API::BuildMessagesController
    end
  end
end
