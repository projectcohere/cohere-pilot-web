module Cases
  module Views
    class Pending < ::Value
      # -- props --
      prop(:id, default: Id::None)
      prop(:program)
    end
  end
end
