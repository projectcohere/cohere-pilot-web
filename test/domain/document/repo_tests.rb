require "test_helper"

class Document
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      document_rec = documents(:document_2_2)

      document = Document::Repo.map_record(document_rec)
      assert_not_nil(document.record)
      assert_not_nil(document.id)
      assert_equal(document.classification, :unclassified)
      assert_not_nil(document.file)
      assert_not_nil(document.source_url)
    end
  end
end
