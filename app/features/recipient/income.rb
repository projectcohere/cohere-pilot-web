class Recipient
  class Income < ::Entity
    prop(:month, default: nil)
    prop(:amount)
    props_end!
  end
end
