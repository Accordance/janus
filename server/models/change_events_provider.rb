require 'mongoid-pagination'

module ChangeEventsProvider
  class ChangeEvent
    include Mongoid::Document
    include Mongoid::Timestamps::Created
    include Mongoid::Pagination

    field :time, type: DateTime
    field :source, type: String
    field :dc, type: String
    field :env, as: :environment, type: String
    field :systems, type: Array, default: []
    field :reference_url, type: String
    field :description, as: :desc, type: String
    field :type, type: String
    field :details, type: Hash

    def time=(time_str)
      super(DateTime.parse(time_str))
    end

    store_in collection: 'change_events'
  end
end
