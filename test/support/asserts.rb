module Support
  module Asserts
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
