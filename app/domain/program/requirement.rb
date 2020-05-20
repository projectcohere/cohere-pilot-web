class Program
  class Requirement < ::Option
    # -- options --
    group(:contract) do
      option(:present)
    end

    group(:supplier_account) do
      option(:present)
      option(:active_service)
    end

    group(:food) do
      option(:dietary_restrictions)
    end

    group(:household) do
      option(:ownership)
      option(:proof_of_income_dhs)
    end
  end
end
