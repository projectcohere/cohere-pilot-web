module Recipient
  class Name < ::Value
    # -- props --
    prop(:first)
    prop(:last)
    props_end!

    # -- queries --
    def to_s
      "#{first} #{last}"
    end
  end
end
