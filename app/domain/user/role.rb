class User
  class Role < ::Value
    # -- props --
    prop(:name)
    prop(:partner_id)

    # -- queries --
    def dhs?
      return @name == Partner::MembershipClass::Governor
    end

    def cohere?
      return @name == Partner::MembershipClass::Cohere
    end

    def supplier?
      return @name == Partner::MembershipClass::Supplier
    end

    def enroller?
      return @name == Partner::MembershipClass::Enroller
    end
  end
end
