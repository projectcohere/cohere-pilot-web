class Case
  class Inbound < ::Form
    # -- props --
    # -- props/name
    attr_accessor(:first_name)
    attr_accessor(:last_name)

    # -- props/utility-account
    attr_accessor(:account_number)
    attr_accessor(:arrears)

    # -- props/phone
    attr_accessor(:phone_number)

    # -- props/address
    attr_accessor(:street)
    attr_accessor(:street2)
    attr_accessor(:city)
    attr_accessor(:state)
    attr_accessor(:zip)
  end
end
