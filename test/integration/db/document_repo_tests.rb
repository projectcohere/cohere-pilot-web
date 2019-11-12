require "test_helper"

module Db
  class DocumentRepoTests < ActiveSupport::TestCase
    test "saves uploaded documents" do
      case_rec = cases(:submitted_2)

      documents = [
        Document.upload(Faker::Internet.url,
          case_id: Id.new(case_rec.id)
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

      record = documents[0].record
      assert_not_nil(record)
      assert_not_nil(record.source_url)
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

    test "saves a new contract" do
      document = Document.generate_contract(
        case_id: Id.new(cases(:pending_1).id)
      )

      document_repo = Document::Repo.new

      act = -> do
        document_repo.save_new_contract(document)
      end

      assert_difference(
        -> { Document::Record.count } => 1,
        &act
      )

      assert_not_nil(document.record)
    end
  end
end
