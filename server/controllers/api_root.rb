require 'grape'
require 'grape-swagger'

require_relative 'api/defaults'
require_relative 'janus_controller'
require_relative 'janus_maintenance_controller'
require_relative 'queues_controller'
require_relative 'deploy_controller'

module API
  class Root < Grape::API
    # http://localhost:8080/api/locks
    mount API::JanusMaintenanceController
    mount API::JanusController
    mount API::QueuesController
    mount API::DeployController

    # before do
    #   header['Access-Control-Allow-Origin'] = '*'
    #   header['Access-Control-Request-Method'] = '*'
    # end

    # http://localhost:8080/api/swagger_doc.json
    # add_swagger_documentation(base_path: 'test')

    add_swagger_documentation hide_documentation_path: true,
                              base_path: (lambda do |request|
                                if RACK_ENV == 'development'
                                  return "http://#{request.host}:#{request.port}"
                                else
                                  return "https://#{request.host}"
                                end
                              end)

    # # base_path: "/api"
    # root_base_path: false,
    # api_version: 'v1',
    # markdown: true,
    # :markdown => true,
    # mount_path: '/v1/swagger_doc',

    route :any, '*path' do
      error! 'Unknown route', 404
    end
  end
end
