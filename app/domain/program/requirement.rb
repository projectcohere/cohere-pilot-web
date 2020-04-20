class Program
  class Requirement < ::Option
    # -- options --
    group(:supplier_account) do
      option(:active_service)
    end

    group(:household) do
      option(:ownership)
      option(:primary_residence)
    end
  end
end
