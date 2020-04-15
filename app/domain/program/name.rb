class Program
  class Name
    include ::Options

    # -- options --
    option(:meap)
    option(:wrap)

    # -- queries --
    def referral_program
      return self == Meap ? Wrap : Meap
    end
  end
end
