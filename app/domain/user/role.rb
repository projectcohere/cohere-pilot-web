class User
  class Role < ::Value
    # -- props --
    prop(:name)
    prop(:partner_id)

    # -- queries --
    def governor?
      return @name == Partner::Membership::Governor
    end

    def cohere?
      return @name == Partner::Membership::Cohere
    end

    def supplier?
      return @name == Partner::Membership::Supplier
    end

    def enroller?
      return @name == Partner::Membership::Enroller
    end
  end
end
