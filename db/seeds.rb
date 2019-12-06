# -- organizations --
supplier_0 = Supplier::Record.create!(
  name: "DTE",
  program: :meap
)

supplier_1 = Supplier::Record.create!(
  name: "Consumers Energy",
  program: :meap
)

supplier_2 = Supplier::Record.create!(
  name: "DWSD",
  program: :wrap
)

enroller_0 = Enroller::Record.create!(
  name: "Wayne Metro"
)
