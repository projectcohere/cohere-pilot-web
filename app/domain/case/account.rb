class Case
  class Account < ::Value
    prop(:number)
    prop(:arrears_cents)
    props_end!

    # -- queries --
    def arrears_dollars
      arrears_cents / 100.0
    end
  end
end
