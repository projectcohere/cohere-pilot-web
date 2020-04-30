# -- constants --
M = Partner::Membership

# -- partners --
meap = Program::Record.create!(
  name: "MEAP",
  contracts: %i[
    meap
  ]
)

wrap = Program::Record.create!(
  name: "WRAP",
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
)

cares_energy = Program::Record.create!(
  name: "Energy (CARES)",
  requirements: {
    supplier_account: %i[
      present
    ],
  },
)

cares_water = Program::Record.create!(
  name: "Water (CARES)",
  requirements: {
    supplier_account: %i[
      present
    ],
  },
)

cares_housing = Program::Record.create!(
  name: "Housing (CARES)",
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
  name: "DTE",
  membership: M::Supplier.key,
  programs: [
    meap,
    cares_energy,
  ],
)

Partner::Record.create!(
  name: "Consumers Energy",
  membership: M::Supplier.key,
  programs: [
    meap,
    cares_energy,
  ],
)

Partner::Record.create!(
  name: "DWSD",
  membership: M::Supplier.key,
  programs: [
    wrap,
    cares_water,
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
