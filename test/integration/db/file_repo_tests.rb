require "test_helper"

module Db
  class FileRepoTests < ActiveSupport::TestCase
    include ActionDispatch::TestProcess::FixtureFile

    test "saves uploaded files" do
      file_repo = File::Repo.new
      file = fixture_file_upload("files/test.txt", "text/plain")
      file_ids = nil

      act = -> do
        file_ids = file_repo.save_uploaded_files([file])
      end

      assert_difference(
        -> { ActiveStorage::Blob.count } => 1,
        &act
      )

      assert_length(file_ids, 1)
    end
  end
end
