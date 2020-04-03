require "active_record/fixtures"

module Environment
  module Fixtures
    # we have to monkey patch the fixture class cache to namespace our fixture
    # classes.
    #
    # in the test environment, set_fixture_class works just fine, however we want to
    # load fixues in dev, and the db:fixtures:load rake task does not provide any mechanism
    # for specifying a class map.
    module ClassCacheExt
      def initialize(class_names, *args, **kwargs, &block)
        @@class_map ||= begin
          require_many("**/record.rb", scope: "app/domain")

          record_types = ApplicationRecord.subclasses
          record_types.each_with_object({}) do |record_type, memo|
            name = record_type.module_parent.name.underscore.gsub("/", "_").pluralize
            memo[name] = record_type
          end
        end

        class_names.merge!(@@class_map)
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
