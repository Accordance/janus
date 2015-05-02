require_relative 'change_events_provider'

module BuildEventsProvider
  class BuildEvent < ChangeEventsProvider::ChangeEvent
    field :job_status_doc, type: Hash
    field :job_status, type: String
    field :event_status, type: String

    def initialize(attrs = nil)
      super(attrs)
      self.type = 'build'
    end
  end

  class DeployEvent < ChangeEventsProvider::ChangeEvent
    field :job_status_doc, type: Hash
    field :job_status, type: String
    field :event_status, type: String

    def initialize(attrs = nil)
      super(attrs)
      self.type = 'deploy'
    end
  end
end
