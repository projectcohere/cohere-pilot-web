class User < ::Entity
  # -- props --
  prop(:id)
  prop(:role)
  prop(:organization)

  # -- liftime --
  def initialize(id:, role:, organization: nil)
    @role = role
    @organization = organization
  end

  # -- factories --
  def self.from_record(record)
    # parse role from org type. if the user has an org with
    # an associated record it will be the record's class name.
    role, org = case record.organization_type
    when "cohere"
      [:cohere, nil]
    when Enroller::Record.to_s
      [:enroller, Enroller.from_record(record.organization)]
    when Supplier::Record.to_s
      [:supplier, Supplier.from_record(record.organization)]
    end

    # create entity
    User.new(
      id: record.id,
      role: role,
      organization: org
    )
  end
end
