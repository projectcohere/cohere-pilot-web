class Case
  class Account < ::Value
    prop(:supplier_id)
    prop(:number)
    prop(:arrears)
    prop(:active_service, predicate: true, default: true)
  end
end
