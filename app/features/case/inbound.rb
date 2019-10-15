class Case
  class Inbound < ::Form
    # -- props --
    # -- props/name
    prop(:first_name, :string, presence: true)
    prop(:last_name, :string, presence: true)

    # -- props/phone
    prop(:phone_number, :string, presence: true)

    # -- props/address
    prop(:street, :string, presence: true)
    prop(:street2, :string)
    prop(:city, :string, presence: true)
    prop(:state, :string, presence: true)
    prop(:zip, :string, presence: true)

    # -- props/utility-account
    prop(:account_number, :string, presence: true)
    prop(:arrears, :string, presence: true)
  end
end
