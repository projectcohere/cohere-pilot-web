class Partner
  module Membership
    # -- options --
    Cohere = :cohere
    Governor = :governor
    Supplier = :supplier
    Enroller = :enroller

    # -- queries --
    def self.all
      @all ||= [
        Cohere,
        Governor,
        Supplier,
        Enroller,
      ]
    end

    def self.index(option)
      return all.find_index(option)
    end
  end
end
