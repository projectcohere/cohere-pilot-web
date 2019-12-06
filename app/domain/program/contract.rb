class Program
  class Contract < ::Value
    prop(:program)
    prop(:variant)
    props_end!

    # -- variants --
    Meap = :meap
    Wrap3h = :wrap_3h
    Wrap1k = :wrap_1k
  end
end
