require "test_helper"

class OptionsTests < ActiveSupport::TestCase
  # -- test classes --
  class Color < ::Option
    option(:red)
    option(:blue)
    option(:green)
  end

  # -- tests --
  test "gets an option" do
    option = Color::Red
    assert_instance_of(Color, option)
  end

  test "gets an option's key" do
    option = Color::Red
    assert_equal(option.key, :red)
  end

  test "tests for a particular option" do
    option = Color::Red
    assert(option.red?)
    assert_not(option.blue?)
  end

  test "gets an option by key" do
    option = Color.from_key("red")
    assert_same(option, Color::Red)
  end

  test "raises an error for unknown options" do
    act = -> do
      Options::Chartreuse
    end

    assert_raises(NameError, &act)
  end
end
