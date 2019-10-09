module Ext
  module Fixtures
    # -- queries --
    def password(password)
      ::BCrypt::Password.create(password, cost: ::BCrypt::Engine::MIN_COST)
    end
  end
end

ActiveRecord::FixtureSet.context_class.include(Ext::Fixtures)
