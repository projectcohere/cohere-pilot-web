class User
  class Record < ApplicationRecord
    include Clearance::User

    # -- associations --
    belongs_to(:partner)

    # -- validations --
    validate(:check_password_requirements, unless: :skip_password_validation?)

    # -- validations/helpers
    private def check_password_requirements
      if password.length < 12
        errors.add(:password, "must be at least 12 characters")
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
