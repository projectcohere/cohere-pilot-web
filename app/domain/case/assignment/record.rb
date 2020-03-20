class Case
  class Assignment
    class Record < ApplicationRecord
      set_table_name!

      # -- associations --
      belongs_to(:case, class_name: "::Case::Record")
      belongs_to(:user, class_name: "::User::Record")
    end
  end
end