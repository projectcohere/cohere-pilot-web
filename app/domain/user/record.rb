class User
  class Record < ::ApplicationRecord
    include Clearance::User

    # -- config --
    set_table_name!

    # -- associations --
    belongs_to(:organization, polymorphic: true, optional: true)

    # -- validations --
    validate(:check_password_requirements, unless: :skip_password_validation?)

    private def check_password_requirements
      if password.length < 8
        errors.add(:password, "must be at least 8 characters")
      end

      if not password.match?(/\w/)
        errors.add(:password, "must have at least one letter")
      end

      if not password.match?(/\d/)
        errors.add(:password, "must have at least one number")
      end

      if not password.match?(/[!@#$%^&*_=+-]/)
        errors.add(:password, "must have at least one symbol")
      end
    end
  end
end
