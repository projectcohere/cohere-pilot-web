module Recipient
  class Name < ::Value
    # -- props --
    prop(:first)
    prop(:last)

    # -- queries --
    def to_s
      "#{first} #{last}"
    end
  end
end
