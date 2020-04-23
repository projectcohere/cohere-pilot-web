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
      active_service
    ],
    household: %i[
      ownership
      primary_residence
    ],
  }
)

# -- partners --
cohere_0 = Partner::Record.create!(
  name: "Cohere",
  membership: M::Cohere.key,
)

governor_0 = Partner::Record.create!(
  name: "MDHHS",
  membership: M::Governor.key,
)

supplier_0 = Partner::Record.create!(
  name: "DTE",
  membership: M::Supplier.key,
  programs: [meap],
)

supplier_1 = Partner::Record.create!(
  name: "Consumers Energy",
  membership: M::Supplier.key,
  programs: [meap],
)

supplier_2 = Partner::Record.create!(
  name: "DWSD",
  membership: M::Supplier.key,
  programs: [wrap],
)

enroller_0 = Partner::Record.create!(
  name: "Wayne Metro",
  membership: M::Enroller.key,
  programs: [meap, wrap],
)
