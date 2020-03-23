require "test_helper"

module Db
  class StatsRepoTests < ActiveSupport::TestCase
    include ActionDispatch::TestProcess::FixtureFile

    test "finds stats for the current round" do
      stats_repo = Stats::Repo.new

      cases(:approved_1).update!(
        created_at: Stats::Repo::StartDate - 1.days,
      )

      stats = stats_repo.find_current
      assert_length(stats.cases, 1)
    end
  end
end
