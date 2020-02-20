class Case
  class Account < ::Value
    prop(:number)
    prop(:arrears_cents)
    prop(:has_active_service, default: true)

    # -- queries --
    def arrears_dollars
      if arrears_cents.nil?
        return nil
      end

      arrears_cents / 100.0
    end
  end
end
