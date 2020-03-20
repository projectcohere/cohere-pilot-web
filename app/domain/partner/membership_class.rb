class Partner
  module MembershipClass
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
  end
end
