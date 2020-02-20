require "test_helper"

class IntializableTests < ActiveSupport::TestCase
  # -- test classes --
  class Color
    include ::Initializable

    prop(:r)
    prop(:g)
    prop(:b, default: 0)
  end

  class Cart
    include ::Initializable

    prop(:items, default: [])
  end

  # -- tests --
  test "can be key-value initialized" do
    color = Color.new(
      r: 255,
      g: 239,
      b: 213
    )

    assert_equal(color.r, 255)
    assert_equal(color.g, 239)
    assert_equal(color.b, 213)
  end

  test "clones default values" do
    cart1 = Cart.new
    cart2 = Cart.new

    cart1.items << "eggs"
    assert_length(cart1.items, 1)
    assert_length(cart2.items, 0)
  end

  test "raises an error for unknown keywords" do
    act = -> do
      Color.new(
        r: 255,
        g: 255,
        z: 255
      )
    end

    assert_raises(ArgumentError, &act)
  end

  test "raises an error for missing keywords" do
    act = -> do
      Color.new(
        r: 255
      )
    end

    assert_raises(ArgumentError, &act)
  end
end
