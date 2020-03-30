# -- constants --
P = Program::Name
M = Partner::Membership

# -- partners --
cohere_0 = Partner::Record.create!(
  name: "Cohere",
  membership: M::Cohere,
)

mdhhs_0 = Partner::Record.create!(
  name: "MDHHS",
  membership: M::Governor,
)

supplier_0 = Partner::Record.create!(
  name: "DTE",
  membership: M::Supplier,
  programs: [P.index(P::Meap)],
)

supplier_1 = Partner::Record.create!(
  name: "Consumers Energy",
  membership: M::Supplier,
  programs: [P.index(P::Meap)],
)

supplier_2 = Partner::Record.create!(
  name: "DWSD",
  membership: M::Supplier,
  programs: [P.index(P::Wrap)],
)

enroller_0 = Partner::Record.create!(
  name: "Wayne Metro",
  membership: M::Enroller,
  programs: [P.index(P::Meap), P.index(P::Wrap)],
)
