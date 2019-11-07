# Internal storage for shared repos. Get a repo using its class-level
# accessor, e.g. `Case::Repo.get`.
class Services < ActiveSupport::CurrentAttributes
  attribute(:event_queue)
  attribute(:enroller_repo)
  attribute(:supplier_repo)
  attribute(:document_repo)
end
