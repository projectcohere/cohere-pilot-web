module Support
  module Asserts
    def assert_present(actual)
      assert(actual.present?, "Expected #{actual} to be present.")
    end

    def assert_length(collection, expected)
      actual = collection.length
      assert(actual == expected, "Expected length to be #{expected}, but was #{actual}")
    end

    def assert_all(collection, predicate)
      assert(collection.all?(predicate), "Expected all elements to match predicate.")
    end
  end
end

ActiveSupport::TestCase.include(Support::Asserts)
