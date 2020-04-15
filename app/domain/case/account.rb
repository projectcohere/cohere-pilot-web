class Case
  class Account < ::Value
    prop(:number)
    prop(:arrears)
    prop(:active_service, predicate: true, default: true)
  end
end
