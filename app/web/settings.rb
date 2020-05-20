class Settings
  include Service::Single

  # -- lifetime --
  def initialize(store: InMemoryStore.get)
    @store = store
    @store.execute do |s|
      @working_hours = s.get(WorkingHoursKey) == WorkingHoursFlag
    end
  end

  # -- commands --
  def save
    @store.execute do |s|
      s.set(WorkingHoursKey, @working_hours ? WorkingHoursFlag : nil)
    end
  end

  # -- hours --
  WorkingHoursKey = "cohere/settings".freeze
  WorkingHoursFlag = "true".freeze

  def working_hours?
    return @working_hours
  end

  def working_hours=(value)
    @working_hours = value
  end
end
