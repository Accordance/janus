require 'grape'
require 'grape-entity'

require_relative 'api/defaults'
require_relative '../../server/models/change_events_provider'
require_relative '../../server/models/build_events_provider'

module API
  class JanusController < Grape::API
    include API::Defaults

    resource :janus do
      get '/' do
        param_limit       = ((URI.unescape(params[:limit]) unless params[:limit].nil?) || '25').to_i
        param_page        = ((URI.unescape(params[:page]) unless params[:page].nil?) || '1').to_i
        param_env         = URI.unescape(params[:env]) unless params[:env].nil?
        param_system_name = URI.unescape(params[:filter]) unless params[:filter].nil?
        param_time_frame  = (URI.unescape(params[:frame]) unless params[:frame].nil?) || '1h'

        query = {}

        unless param_system_name.nil?
          query['systems'] = { '$all' => [param_system_name] }
        end
        query['env'] = param_env unless param_env.nil?
        unless param_time_frame.nil?
          start_time = Time.now
          case param_time_frame
          when '1h'
            start_time -= 60 * 60
          when '6h'
            start_time -= 60 * 60 * 6
          when '12h'
            start_time -= 60 * 60 * 12
          when '1d'
            start_time -= 60 * 60 * 24
          when '1w'
            start_time -= 60 * 60 * 24 * 7
          end

          query['created_at'] = { '$gte' => "ISODate('#{start_time.utc.iso8601}')" }
        end

        ChangeEventsProvider::ChangeEvent
          .without(:job_status_doc)
          .desc('time')
          .and(query)
          .paginate(page: param_page, limit: param_limit)
      end

      get '/:id' do
        ChangeEventsProvider::ChangeEvent
          .without(:job_status_doc)
          .find(params[:id])
          .as_document
      end
    end
  end
end
