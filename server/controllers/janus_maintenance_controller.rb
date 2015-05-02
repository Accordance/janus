require 'grape'
require 'grape-entity'

require_relative 'api/defaults'
require_relative '../../server/models/maintenance_event_provider'

module API
  class JanusMaintenanceController < Grape::API
    include API::Defaults

    prefix :janus

    resource :maintenanceEvents do
      get '/' do
        param_limit   = (URI.unescape(params[:limit]) unless params[:limit].nil?) || '100'
        limit_records = param_limit.to_i

        MaintenanceEventProvider::MaintenanceEvent
          .desc('time_frame.start')
          .paginate(page: 1, limit: limit_records)
      end
    end
  end
end
