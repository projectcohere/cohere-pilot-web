# -- constants --
P = Program::Name
M = Partner::MembershipClass

# -- partners --
cohere_0 = Partner::Record.create!(
  name: "Cohere"
  membership_class: M::Cohere,
)

mdhhs_0 = Partner::Record.create!(
  name: "MDHHS"
  membership_class: M::Governor,
)

supplier_0 = Partner::Record.create!(
  name: "DTE",
  membership_class: M::Supplier,
  programs: [P.index(P::Meap)],
)

supplier_1 = Partner::Record.create!(
  name: "Consumers Energy",
  membership_class: M::Supplier,
  programs: [P.index(P::Meap)],
)

supplier_2 = Partner::Record.create!(
  name: "DWSD",
  membership_class: M::Supplier,
  programs: [P.index(P::Wrap)],
)

enroller_0 = Partner::Record.create!(
  name: "Wayne Metro",
  membership_class: M::Enroller,
  programs: [P.index(P::Meap), P.index(P::Wrap)],
)
