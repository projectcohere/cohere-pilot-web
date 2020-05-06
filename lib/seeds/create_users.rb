# builds a partner record
def user(email, role)
  return User::Record.new(
    email: email,
    role: role.key,
    password: "password123$"
  )
end

# build partner -> users map
users = {
  "Cohere" => [
    user("me@projectcohere.com", Role::Agent),
  ],
  "MDHHS" => [
    user("me@michigan.gov", Role::Governor),
  ],
  "DTE" => [
    user("me@dteenergy.com", Role::Source),
  ],
  "Consumers Energy" => [
    user("me@consumersenergy.com", Role::Source),
  ],
  "DWSD" => [
    user("me@dwsd.gov", Role::Source),
  ],
  "Wayne Metro" => [
    user("enroll@waynemetro.org", Role::Enroller),
    user("source@waynemetro.org", Role::Source),
  ],
}

# add users to partner
ps = Partner::Record.where(name: users.keys)
ps.each do |p|
  p.users.concat(users[p.name])
end
