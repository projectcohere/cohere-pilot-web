require "test_helper"

class Document
  class RepoTests < ActiveSupport::TestCase
    test "saves uploaded documents" do
      kase = cases(:submitted_2)

      documents = [
        Document.new(
          case_id: Id.new(kase.id),
          source_url: Faker::Internet.url
        )
      ]

      act = -> do
        repo = Document::Repo.new
        repo.save_uploaded(documents)
      end

      assert_difference(
        -> { Document::Record.count } => 1,
        &act
      )

      assert_all(documents, ->(d) { d.record.present? })
    end

    test "saves an attached file" do
      document = Document::Repo.map_record(documents(:document_2_2))
      document.attach_file(FileData.new(
        data: StringIO.new("test-data"),
        name: "test.txt",
        mime_type: "text/plain"
      ))

      act = -> do
        repo = Document::Repo.new
        repo.save_attached_file(document)
      end

      act.()
    end

    test "maps a record" do
      document = Document::Repo.map_record(documents(:document_2_2))
      assert_not_nil(document.id)
    end
  end
end
