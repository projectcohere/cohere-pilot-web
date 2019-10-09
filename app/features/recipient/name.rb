class Recipient
  class Name
    # -- properties --
    attr_reader(:first)
    attr_reader(:last)

    # -- lifetime --
    def initialize(first:, last:)
      @first = first
      @last = last
    end

    # -- queries --
    def to_s
      "#{first} #{last}"
    end
  end
end
