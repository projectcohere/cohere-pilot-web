require "test_helper"
require "minitest/mock"

class Document
  class SyncSourceFileTests < ActiveSupport::TestCase
    test "attaches a source file" do
      document = Document.stub(
        source_url: Faker::Internet.url
      )

      document_repo = Minitest::Mock.new
        .expect(:find, document, ["test-id"])
        .expect(:save_attached_file, nil, [document])

      sync_source_file = SyncSourceFile.new(
        download_file: ->(_) { "test-file" },
        document_repo: document_repo
      )

      sync_source_file.("test-id")
      assert_equal(document.new_file, "test-file")
    end
  end
end
