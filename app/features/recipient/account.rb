class Recipient
  class Account < ::Entity
    prop(:supplier)
    prop(:number)
    prop(:arrears)
    props_end!
  end
end
