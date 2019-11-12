require "test_helper"

class Document
  class RepoTests < ActiveSupport::TestCase
    test "saves uploaded documents" do
      case_rec = cases(:submitted_2)

      documents = [
        Document.new(
          case_id: Id.new(case_rec.id),
          source_url: Faker::Internet.url
        )
      ]

      document_repo = Document::Repo.new

      act = -> do
        document_repo.save_uploaded(documents)
      end

      assert_difference(
        -> { Document::Record.count } => 1,
        &act
      )

      assert_all(documents, ->(d) { d.record.present? })
    end

    test "saves an attached file" do
      document_rec = documents(:document_2_2)
      document = Document::Repo.map_record(document_rec)
      document.attach_file(Documents::File.new(
        data: StringIO.new("test-data"),
        name: "test.txt",
        mime_type: "text/plain"
      ))

      document_repo = Document::Repo.new

      act = -> do
        document_repo.save_attached_file(document)
      end

      assert_difference(
        -> { ActiveStorage::Attachment.count } => 1,
        -> { ActiveStorage::Blob.count } => 1,
        &act
      )
    end

    test "maps a record" do
      document_rec = documents(:document_2_2)

      document = Document::Repo.map_record(document_rec)
      assert_not_nil(document.record)
      assert_not_nil(document.id)
      assert_not_nil(document.file)
      assert_not_nil(document.source_url)
      assert_not_nil(document.case_id)
    end
  end
end
