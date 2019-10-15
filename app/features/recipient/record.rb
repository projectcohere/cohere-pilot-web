class Recipient
  class Record < ::ApplicationRecord
    # TODO: generalize this for feature-namespaced records?
    self.table_name = :recipients

    # -- associations --
    has_many(:cases)
  end
end
