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

    group(:household) do
      option(:ownership)
    end
  end
end
