class Case
  class Assignment < ::Entity
    # -- props --
    prop(:role)
    prop(:user_id)
    prop(:user_email)
    prop(:partner_id)

    # -- commands --
    def remove
      @removed = true
    end

    # -- queries --
    def removed?
      return @removed
    end
  end
end
