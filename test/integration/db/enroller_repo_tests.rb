require "test_helper"

module Db
  class EnrollerRepoTests < ActiveSupport::TestCase
    test "finds an enroller" do
      enroller_repo = Enroller::Repo.new
      enroller_id = enrollers(:enroller_1).id

      enroller = enroller_repo.find(enroller_id)
      assert_not_nil(enroller)
      assert_equal(enroller.id, enroller_id)
    end

    test "finds the default enroller" do
      enroller_repo = Enroller::Repo.new

      enroller = enroller_repo.find_default
      assert_not_nil(enroller)
      assert_equal(enroller, enroller_repo.find_default)
    end

    test "finds many enrollers" do
      enroller_repo = Enroller::Repo.new
      enroller_ids = [
        enrollers(:enroller_1).id,
        enrollers(:enroller_2).id
      ]

      enrollers = enroller_repo.find_many(enroller_ids)
      assert_length(enrollers, 2)
      assert_same_elements(enrollers.map(&:id), enroller_ids)
    end
  end
end
