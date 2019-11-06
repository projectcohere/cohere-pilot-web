require "test_helper"

class Recipient
  class Document
    class RepoTests < ActiveSupport::TestCase
      test "saves a new file" do
        document = Recipient::Document::Repo.map_record(documents(:document_2_2))
        document.attach_file(FileData.new(
          data: StringIO.new("test-data"),
          name: "test.txt",
          mime_type: "text/plain"
        ))

        act = -> do
          repo = Recipient::Document::Repo.new
          repo.save_new_file(document)
        end

        act.()
      end
    end
  end
end
