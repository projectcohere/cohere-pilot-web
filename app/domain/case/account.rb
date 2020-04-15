class Case
  class Account < ::Value
    prop(:number)
    prop(:arrears)
    prop(:has_active_service, default: true)
  end
end
