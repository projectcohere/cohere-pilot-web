class User
  class Role < ::Value
    # -- props --
    prop(:name)
    prop(:organization_id, default: nil)
    props_end!

    # -- factories --
    def self.named(name)
      Role.new(name: name)
    end
  end
end
