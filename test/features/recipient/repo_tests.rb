require "test_helper"

class Recipient
  class RepoTests < ActiveSupport::TestCase
    test "finds a recipient by phone number" do
      record = recipients(:recipient_1)

      repo = Recipient::Repo.new
      recipient = repo.find_one_by_phone_number(record.phone_number)
      assert_not_nil(recipient)
      assert_equal(recipient.phone_number, record.phone_number)
    end

    test "saves new documents" do
      recipient = Recipient.from_record(recipients(:recipient_1))
      recipient.documents << Recipient::Document.new(
        source_url: "https://website.com/image.jpg"
      )

      act = -> do
      repo = Recipient::Repo.new
        repo.save_new_documents(recipient)
      end

      assert_difference(
        -> { Document::Record.count } => 1,
        &act
      )

      assert_all(recipient.documents, ->(d) { d.id.present? })
    end
  end
end
