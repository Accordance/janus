require 'mongoid-pagination'

module MaintenanceEventProvider
  class MaintenanceEvent
    include Mongoid::Document
    include Mongoid::Timestamps::Created
    include Mongoid::Pagination

    field :_id, type: String, pre_processed: true, default: -> { Moped::BSON::ObjectId.new.to_s }
    field :time_frame, type: Hash, default: {}  # start/end DateTime
    field :source, type: String
    field :dc, type: String
    field :env, as: :environment, type: String
    field :systems, type: Array, default: []
    field :reference_url, type: String
    field :description, as: :desc, type: String  # summary
    field :type, type: String
    field :details, type: Hash
    field :assignee, type: Hash
    # field :status, :type => Symbol, :default => :unknown

    def time_frame_str=(time_start_str, time_end_str)
      super.time_frame = { start: DateTime.parse(time_start_str), end: DateTime.parse(time_end_str) }
    end

    store_in collection: 'maintenance_events'
  end
end
