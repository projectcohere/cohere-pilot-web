require "active_record/fixtures"

module Environment
  module Fixtures
    # provide the namespace paths to our active record models
    # TODO: generate this from a list of descendants of ApplicationRecord
    # named Record.
    K_ClassMap = {
      users: User::Record,
      suppliers: Supplier::Record,
      enrollers: Enroller::Record,
      cases: Case::Record,
      recipients: Recipient::Record,
      accounts: Recipient::Account::Record,
      households: Recipient::Household::Record
    }

    # we have to monkey patch the fixture class cache to namespace our fixture
    # classes.
    #
    # in the test environment, set_fixture_class works just fine, however in dev
    # the db:fixtures:load rake task does not provide any mechanism for specifying
    # the class map.
    module ClassCacheExt
      def initialize(class_names, *args, **kwargs, &block)
        class_names.merge!(K_ClassMap)
        super(class_names, *args, **kwargs, &block)
      end
    end

    ActiveRecord::FixtureSet::ClassCache.prepend(ClassCacheExt)

    # add helpers to fixtures context
    module ContextExt
      # -- queries --
      def password(password)
        ::BCrypt::Password.create(password, cost: ::BCrypt::Engine::MIN_COST)
      end
    end

    ActiveRecord::FixtureSet.context_class.include(ContextExt)
  end
end
