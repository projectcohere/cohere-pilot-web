# -- organizations --
supplier_0 = Supplier::Record.create!(
  name: "DTE"
)

supplier_1 = Supplier::Record.create!(
  name: "Consumers Energy"
)

enroller_0 = Enroller::Record.create!(
  name: "Wayne Metro"
)

# -- users --
# TODO: add a diceware password generator to create accounts for everyone
User::Record.create!(
  email: "me@cohere.org",
  password: "password",
  organization_type: :cohere
)

User::Record.create!(
  email: "me@dteenergy.com",
  password: "password",
  organization: supplier_0
)

User::Record.create!(
  email: "me@consumersenergy.com",
  password: "password",
  organization: supplier_1
)

User::Record.create!(
  email: "me@michigan.gov",
  password: "password",
  organization_type: :dhs
)

User::Record.create!(
  email: "me@waynemetro.org",
  password: "password",
  organization: enroller_0
)
