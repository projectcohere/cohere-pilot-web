require "test_helper"

class Case
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      case_rec = cases(:approved_2)

      kase = Case::Repo.map_record(case_rec,
        documents: case_rec.documents,
        assignments: case_rec.assignments,
      )

      assert_not_nil(kase.record)
      assert_not_nil(kase.id.val)
      assert(kase.status&.approved?)
      assert_not_nil(kase.recipient)
      assert_not_nil(kase.enroller_id)
      assert_not_nil(kase.supplier_account)
      assert_not_nil(kase.received_message_at)
      assert_not_nil(kase.updated_at)
      assert_not_nil(kase.completed_at)
      assert(kase.new_activity?)

      recipient = kase.recipient
      assert_not_nil(recipient.record)
      assert_not_nil(recipient.id.val)
      assert_not_nil(recipient.profile)
      assert_not_nil(recipient.household)

      document = kase.documents[0]
      assert_not_nil(document.record)
      assert_not_nil(document.id.val)
      assert_equal(document.classification, :contract)
      assert_not_nil(document.file)
      assert_not_nil(document.source_url)

      assignment = kase.assignments[0]
      assert_not_nil(assignment.user_id)
      assert_not_nil(assignment.user_email)
      assert_not_nil(assignment.partner_id)
    end
  end
end
