module Cases
  class InboundForm < ::ApplicationForm
    # -- fields --
    # -- fields/name
    field(:first_name, :string, presence: true)
    field(:last_name, :string, presence: true)

    # -- fields/phone
    field(:phone_number, :string, presence: true)

    # -- fields/address
    field(:street, :string, presence: true)
    field(:street2, :string)
    field(:city, :string, presence: true)
    field(:state, :string, presence: true)
    field(:zip, :string, presence: true)

    # -- fields/utility-account
    field(:account_number, :string, presence: true)
    field(:arrears, :string, presence: true)

    # -- lifetime --
    def initialize(
      kase = nil,
      supplier_id = nil,
      attrs = {},
      cases: Case::Repo.get,
      suppliers: Supplier::Repo.get,
      enrollers: Enroller::Repo.get
    )
      # set dependencies
      @cases = cases
      @suppliers = suppliers
      @enrollers = enrollers

      # set params
      @supplier_id = supplier_id

      # set underlying model
      @model = kase

      if not kase.nil?
        # set initial values from case
        c = kase
        a = c.account
        assign_defaults!(attrs, {
          account_number: a.number,
          arrears: a.arrears
        })

        # set initial values from recipient
        r = kase.recipient
        p = r.profile.phone
        assign_defaults!(attrs, {
          phone_number: p.number
        })

        n = r.profile.name
        assign_defaults!(attrs, {
          first_name: n.first,
          last_name: n.last
        })

        a = r.profile.address
        assign_defaults!(attrs, {
          street: a.street,
          street2: a.street2,
          city: a.city,
          state: a.state,
          zip: a.zip,
        })
      end

      super(attrs)
    end

    # -- commands --
    def save
      if not valid?
        return false
      end

      # open a new case for the recipient
      enroller = @enrollers.find_default()
      supplier = @suppliers.find(@supplier_id)

      new_case = supplier.open_case(enroller,
        account: map_to_supplier_account,
        profile: map_to_recipient_profile,
      )

      @cases.save_opened(new_case)

      # set underlying model
      @model = new_case

      true
    end

    # -- commands/helpers
    def map_to_supplier_account
      Case::Account.new(
        number: account_number,
        arrears: arrears
      )
    end

    def map_to_recipient_profile
      Recipient::Profile.new(
        phone: Recipient::Phone.new(
          number: phone_number
        ),
        name: Recipient::Name.new(
          first: first_name,
          last: last_name,
        ),
        address: Recipient::Address.new(
          street: street,
          street2: street2,
          city: city,
          state: state,
          zip: zip
        )
      )
    end

    # -- queries --
    def case_id
      @model&.id
    end

    # -- ApplicationForm --
    def self.entity_type
      Case
    end
  end
end
