class Case
  class Note
    class Record < ApplicationRecord
      # -- associations --
      belongs_to(:case)
      belongs_to(:user)
    end
  end
end
