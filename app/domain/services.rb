# Internal storage for shared repos. Get a repo using its class-level
# accessor, e.g. `Case::Repo.get`.
class Services < ActiveSupport::CurrentAttributes
  attribute(:events)
  attribute(:enrollers)
  attribute(:suppliers)
  attribute(:documents)
end
