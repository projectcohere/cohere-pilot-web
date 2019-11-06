# Internal storage for shared repos. Get a repo using its class-level
# accessor, e.g. `Case::Repo.get`.
class Repos < ActiveSupport::CurrentAttributes
  attribute(:enrollers)
  attribute(:suppliers)
end
