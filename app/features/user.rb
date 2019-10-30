class User < ::Entity
  # -- props --
  prop(:id)
  prop(:role)
  prop(:organization, default: nil)
  props_end!

  # -- factories --
  def self.from_record(r)
    # parse role from org type. if the user has an org with
    # an associated record it will be the record's class name.
    role, org = case r.organization_type
    when "cohere"
      [:cohere, nil]
    when "dhs"
      [:dhs, nil]
    when Enroller::Record.to_s
      [:enroller, Enroller.from_record(r.organization)]
    when Supplier::Record.to_s
      [:supplier, Supplier.from_record(r.organization)]
    end

    # create entity
    User.new(
      id: r.id,
      role: role,
      organization: org
    )
  end
end
