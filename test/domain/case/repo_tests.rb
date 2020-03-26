require "test_helper"

class Case
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      case_rec = cases(:approved_2)

      kase = Case::Repo.map_record(case_rec, documents: case_rec.documents, is_referrer: true)
      assert_not_nil(kase.record)
      assert_not_nil(kase.id.val)
      assert_not_nil(kase.status)
      assert_not_nil(kase.recipient)
      assert_not_nil(kase.enroller_id)
      assert_not_nil(kase.supplier_id)
      assert_not_nil(kase.supplier_account)
      assert_not_nil(kase.received_message_at)
      assert_not_nil(kase.updated_at)
      assert_not_nil(kase.completed_at)
      assert(kase.has_new_activity)
      assert(kase.is_referrer)
      assert_not(kase.is_referred)

      recipient = kase.recipient
      assert_not_nil(recipient.record)
      assert_not_nil(recipient.id.val)
      assert_not_nil(recipient.profile)
      assert_not_nil(recipient.dhs_account)

      document = kase.documents[0]
      assert_not_nil(document.record)
      assert_not_nil(document.id.val)
      assert_equal(document.classification, :contract)
      assert_not_nil(document.file)
      assert_not_nil(document.source_url)
    end

    test "maps a referral" do
      case_rec = cases(:referral_1)

      kase = Case::Repo.map_record(case_rec, documents: case_rec.documents)
      assert_not(kase.is_referrer)
      assert(kase.is_referred)
      assert(kase.supplier_account.has_active_service)

      household = kase.recipient.dhs_account.household
      assert_equal(household.ownership, :unknown)
      assert(household.is_primary_residence)
    end
  end
end
