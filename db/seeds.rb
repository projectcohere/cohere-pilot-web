# -- organizations --
enroller = Enroller::Record.create!(
  name: "Wayne Metro"
)

# -- users --
# TODO: add a diceware password generator to create accounts for everyone
User::Record.create!(
  email: "ty@civilla.com",
  password: "password",
  organization_type: :cohere
)

User::Record.create!(
  email: "shama@waynemetro.com",
  password: "password",
  organization: enroller
)
