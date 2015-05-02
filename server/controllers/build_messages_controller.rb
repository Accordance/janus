require 'grape'
require 'grape-entity'

require_relative 'api/defaults'
require_relative '../models/deployment_locks_provider'

module API
  # curl -k -v -X POST -d "message={ \"app\": [\"test1,test2\"], \"artifact_version\": \"v0.1.2\", \
  # \"env\": \"f1\", \"action\": \"deploy\", \"status_url\" : \"http://buildserver.accordance.net/jenkins/job/deploy-app/206/api/json\", \
  # \"status\": \"finished\", \"server\": \"server01\", \"mc\": \"false\" }" http://localhost:8081/queues/build-messages

  module Entities
    class BuildEvent < Grape::Entity
      expose :app, documentation: { type: 'string', required: true, is_array: true }
      expose :artifact_version, documentation: { type: 'string', required: true }
      expose :env, documentation: { type: 'string', required: true }
      expose :action, documentation: { type: 'string', required: true, enum: %w(build deploy) }
      expose :status_url, documentation: { type: 'string', required: false, desc: 'Url that may contain more data' }
      expose :status, documentation: { type: 'string', required: true, enum: %w(started finished) }
      expose :server, documentation: { type: 'string', required: true }
      expose :mc, documentation: { type: 'boolean', required: true }
    end
  end

  class BuildMessagesController < Grape::API
    include API::Defaults

    resource 'build-messages' do
      desc 'Post build events.',
           nickname: 'buildMessages',
           notes: 'Enqueues the build events for post-processing'
      params do
        # optional :body,
        #          type: API::Entities::BuildEvent,
        #          desc: 'Build event'
        requires :message, type: String
      end
      post '/', http_codes: [
        [201, 'OK'],
        [400, 'Bad Request'],
        [401, 'Unauthorized']
      ]  do
        params[:message].gsub! "\r", ''
        params[:message].gsub! "\n", ''
        data = JSON.parse(params[:message])
        message = Hash[data.map { |(k, v)| [k.to_sym, v] }]
        # message = API::Entities::BuildEvent.represent(data, serializable: true)
        message[:time] = DateTime.now.iso8601
        message[:agent] = headers['User-Agent'] unless headers['User-Agent'].nil?

        process_build_messages(message)
      end

      get '/' do
        puts 'blah'
      end
    end

    helpers do
      def process_build_messages(message)
        case message[:action].downcase
        when 'build'
          JobProcessors::ProcessBuildJob.perform_async(JSON.generate(message))
        when 'deploy'
          status = message[:status]
          env = message[:env]

          process_deploy status, env, message
        else
          fail UnknownAction, 'Action'
        end
      end

      def process_deploy(status, env, message)
        lock_id = "#{env}:master"
        if status == 'started'
          lock = DeploymentLocksProvider.fetch_by_id(lock_id)

          if lock.nil?
            logger.error "Can't find lock by ID: '#{lock_id}'"
          else
            if lock.active
              note = lock.note || 'Deployment lock is active'
              error! note, 401
            end
          end
        end

        Sidekiq::Client.push('class' => 'JobProcessors::ProcessBuildJob', 'args' => [message])
        {}
      end
    end
  end
end
