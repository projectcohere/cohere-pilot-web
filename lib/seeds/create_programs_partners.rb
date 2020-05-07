# -- constants --
M = Partner::Membership

# -- partners --
meap = Program::Record.create!(
  name: "MEAP",
  priority: -1,
  contracts: %i[
    meap
  ]
)

wrap = Program::Record.create!(
  name: "WRAP",
  priority: 4,
  contracts: %i[
    wrap_3h
    wrap_1k
  ],
  requirements: {
    supplier_account: %i[
      present
      active_service
    ],
    household: %i[
      ownership
    ],
  }
)

cares_food = Program::Record.create!(
  name: "Food (CARES)",
  priority: 0,
)

cares_energy = Program::Record.create!(
  name: "Energy (CARES)",
  priority: 1,
  requirements: {
    supplier_account: %i[
      present
    ],
  },
)

cares_water = Program::Record.create!(
  name: "Water (CARES)",
  priority: 2,
  requirements: {
    supplier_account: %i[
      present
    ],
  },
)

cares_housing = Program::Record.create!(
  name: "Housing (CARES)",
  priority: 3,
  requirements: {
    household: %i[
      ownership
    ],
  },
)

# -- partners --
Partner::Record.create!(
  name: "Cohere",
  membership: M::Cohere.key,
)

Partner::Record.create!(
  name: "MDHHS",
  membership: M::Governor.key,
  programs: [
    meap,
  ],
)

Partner::Record.create!(
  name: "Wayne Metro",
  membership: M::Enroller.key,
  programs: [
    meap,
    wrap,
    cares_food,
    cares_energy,
    cares_water,
    cares_housing,
  ],
)

# -- partners/energy
suppliers = [
  "DTE",
  "Consumers Energy",
  "WMS",
]

suppliers.each do |name|
  Partner::Record.create!(
    name: name,
    membership: M::Supplier.key,
    programs: [
      meap,
      cares_energy,
    ],
  )
end

# -- partners/water
suppliers = [
  "DWSD",
  "Brownstown Township",
  "Canton Township",
  "City of Allen Park",
  "City of Belleville",
  "City of Dearborn",
  "City of Dearborn Heights",
  "City of Detroit",
  "City of Ecorse",
  "City of Flat Rock",
  "City of Garden City",
  "City of Gibraltar",
  "City of Grosse Pointe Farms",
  "City of Grosse Pointe Park",
  "City of Grosse Pointe Woods",
  "City of Hamtramck",
  "City of Harper Woods",
  "City of Highland Park",
  "City of Inkster",
  "City of Lincoln Park",
  "City of Livonia",
  "City of Melvindale",
  "City of Northville",
  "City of Plymouth",
  "City of River Rouge",
  "City of Riverview",
  "City of Rockwood",
  "City of Romulus",
  "City of Southgate",
  "City of Taylor",
  "City of Trenton",
  "City of Wayne",
  "City of Westland",
  "City of Woodhaven",
  "City of Wyandotte",
  "Great Lakes Water Authority",
  "Grosse Ile Township",
  "Grosse Pointe City",
  "Grosse Pointe Township",
  "Huron Charter Township",
  "Northville Township",
  "Plymouth Charter Township",
  "Redford Charter Township",
  "Sumpter Township",
  "Van Buren Township",
  "Village of Grosse Pointe Shores",
]

suppliers.each do |name|
  Partner::Record.create!(
    name: name,
    membership: M::Supplier.key,
    programs: [
      wrap,
      cares_water,
    ],
  )
end
