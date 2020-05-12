require "test_helper"

module Db
  class ProgramRepoTests < ActiveSupport::TestCase
    # -- queries --
    # -- queries/many
    test "finds all available programs for a recipient" do
      program_repo = Program::Repo.new

      recipient_rec = recipients(:recipient_3)
      programs = program_repo.find_all_available(recipient_rec.id)
      assert_length(programs, 5)

      recipient_rec = recipients(:recipient_2)
      programs = program_repo.find_all_available(recipient_rec.id)
      assert_length(programs, 3)
    end
  end
end
