module Support
  module Asserts
    def assert_present(actual)
      assert(actual.present?, "Expected #{actual} to be present.")
    end

    def assert_blank(actual)
      assert(actual.blank?, "Expected #{actual} to be blank.")
    end

    def assert_length(collection, expected)
      actual = collection.length
      assert(actual == expected, "Expected length to be #{expected}, but was #{actual}")
    end

    def assert_empty(collection)
      assert(collection.length == 0, "Expected #{collection} to be empty.")
    end

    def assert_all(collection, predicate)
      assert(collection.all?(predicate), "Expected all elements to match predicate.")
    end

    def assert_same_elements(actual, expected)
      assert_equal(actual.sort, expected.sort)
    end

    def assert_instances_of(actual, expected)
      assert_equal(actual.map(&:class), expected)
    end

    def assert_entry(actual, key)
      assert_not_nil(actual)
      assert_present(actual[key])
    end
  end
end

ActiveSupport::TestCase.include(Support::Asserts)
