module DeploymentLocksProvider
  class DeploymentLock
    include Mongoid::Document
    include Mongoid::Timestamps::Created

    field :_id, type: String # , default: ->{ userId }
    field :environment, type: String
    field :note, type: String
    field :active, type: Boolean

    store_in collection: 'deployment_locks'
  end

  def self.fetch_by_id(id)
    DeploymentLock.find(id)
  end

  def self.create_lock(lock_data)
    lock = DeploymentLock.new(
      environment: lock_data[:environment],
      note: lock_data[:note],
      active: true
    )
    lock[:_id] = "#{lock_data[:environment]}:master"
    lock.save
  end

  def self.activate(id, note)
    DeploymentLock.where(_id: id).update(active: true, note: note)
  end

  def self.deactivate(id, note)
    DeploymentLock.where(_id: id).update(active: false, note: note)
  end
end
