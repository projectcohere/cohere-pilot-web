module Cases
  class SupplierForm < ::ApplicationForm
    # -- fields --
    # -- fields/name
    field(:first_name, :string, presence: true)
    field(:last_name, :string, presence: true)

    # -- fields/phone
    field(:phone_number, :string,
      presence: true, numericality: true, length: { is: 10 }
    )

    # -- fields/address
    field(:street, :string, presence: true)
    field(:street2, :string)
    field(:city, :string, presence: true)
    field(:zip, :string,
      presence: true, numericality: true
    )

    # -- fields/utility-account
    field(:account_number, :string)
    field(:arrears, :string, numericality: true, allow_blank: true)
    field(:has_active_service, :boolean)

    validate(:has_account_unless_referral)

    # -- lifetime --
    def initialize(
      model = nil,
      attrs = {},
      case_repo: Case::Repo.get,
      supplier_repo: Supplier::Repo.get,
      enroller_repo: Enroller::Repo.get
    )
      @case_repo = case_repo
      @supplier_repo = supplier_repo
      @enroller_repo = enroller_repo
      super(model, attrs)
    end

    protected def initialize_attrs(attrs)
      if @model.nil?
        return
      end

      c = @model
      a = c.supplier_account
      assign_defaults!(attrs, {
        account_number: a&.number,
        arrears: a&.arrears_dollars&.to_s,
        has_active_service: a&.has_active_service
      })

      r = c.recipient
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
        zip: a.zip,
      })
    end

    # -- commands --
    def save
      if not valid?
        return false
      end

      # open a new case for the recipient
      enroller = @enroller_repo.find_default
      supplier = @supplier_repo.find_current

      new_case = supplier.open_case(enroller,
        profile: map_to_recipient_profile,
        account: map_to_supplier_account,
      )

      @case_repo.save_opened(new_case)

      # set underlying model
      @model = new_case

      true
    end

    # -- commands/sanitization
    def phone_number=(value)
      value&.gsub!(/\D+/, "") # strip non-numeric characters
      super
    end

    def arrears=(value)
      value&.gsub!(/[^\d\.]+/, "") # strip non-decimal characters
      super
    end

    # -- commands/cosmetics
    def first_name=(value)
      super(beautify(value))
    end

    def last_name=(value)
      super(beautify(value))
    end

    def street=(value)
      super(beautify(value))
    end

    def street2=(value)
      super(beautify(value))
    end

    def city=(value)
      super(beautify(value))
    end

    private def beautify(value)
      if not value.nil?
        value.strip.titlecase
      end
    end

    # -- commands/helpers
    def map_to_supplier_account
      Case::Account.new(
        number: account_number,
        arrears_cents: (arrears.to_i * 100.0).to_i,
        has_active_service: has_active_service.nil? ? true : has_active_service
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
          state: "MI",
          zip: zip
        )
      )
    end

    # -- queries --
    def case_id
      @model&.id
    end

    def wrap?
      false
    end

    # -- validations --
    def has_account_unless_referral
      if validation_context == :referral
        return
      end

      if account_number.blank?
        errors.add(:account_number, "can't be blank")
      end

      if arrears.blank?
        errors.add(:arrears, "can't be blank")
      end
    end

    # -- ApplicationForm --
    def self.entity_type
      Case
    end
  end
end
