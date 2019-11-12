require "test_helper"

class Enroller
  class RepoTests < ActiveSupport::TestCase
    test "finds an enroller" do
      repo = Enroller::Repo.new
      enroller_id = enrollers(:enroller_1).id
      enroller = repo.find(enroller_id)
      assert_not_nil(enroller)
      assert_equal(enroller.id, enroller_id)
    end

    test "finds the default enroller" do
      repo = Enroller::Repo.new
      enroller = repo.find_default
      assert_not_nil(enroller)
      assert_equal(enroller, repo.find_default)
    end

    test "finds many enrollers" do
      repo = Enroller::Repo.new
      enroller_ids = [
        enrollers(:enroller_1).id,
        enrollers(:enroller_2).id
      ]

      enrollers = repo.find_many(enroller_ids)
      assert_length(enrollers, 2)
      assert_same_elements(enrollers.map(&:id), enroller_ids)
    end

    test "maps a record" do
      enroller = Enroller::Repo.map_record(enrollers(:enroller_1))
      assert_not_nil(enroller.id)
      assert_not_nil(enroller.name)
    end
  end
end
