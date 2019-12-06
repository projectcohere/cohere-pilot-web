module Program
  class Contract < ::Value
    prop(:program)
    prop(:variant)
    props_end!

    # -- factories --
    def self.meap
      Contract.new(program: Program::Meap, variant: Variant::Meap)
    end

    def self.wrap_3h
      Contract.new(program: Program::Wrap, variant: Variant::Wrap3h)
    end

    def self.wrap_1k
      Contract.new(program: Program::Wrap, variant: Variant::Wrap1k)
    end

    # -- children --
    module Variant
      Meap = :meap
      Wrap3h = :wrap_3h
      Wrap1k = :wrap_1k
    end
  end
end
