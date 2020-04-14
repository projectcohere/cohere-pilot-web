# -- constants --
P = Program::Name
M = Partner::Membership

# -- partners --
cohere_0 = Partner::Record.create!(
  name: "Cohere",
  membership: M::Cohere.key,
)

mdhhs_0 = Partner::Record.create!(
  name: "MDHHS",
  membership: M::Governor.key,
)

supplier_0 = Partner::Record.create!(
  name: "DTE",
  membership: M::Supplier.key,
  programs: [P::Meap.index],
)

supplier_1 = Partner::Record.create!(
  name: "Consumers Energy",
  membership: M::Supplier.key,
  programs: [P::Meap.index],
)

supplier_2 = Partner::Record.create!(
  name: "DWSD",
  membership: M::Supplier.key,
  programs: [P::Wrap.index],
)

enroller_0 = Partner::Record.create!(
  name: "Wayne Metro",
  membership: M::Enroller.key,
  programs: [P::Meap.index, P::Wrap.index],
)
