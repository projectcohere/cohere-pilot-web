require "test_helper"

class Case
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      case_rec = cases(:submitted_1)

      kase = Case::Repo.map_record(case_rec)
      assert_not_nil(kase.record)
      assert_not_nil(kase.id.val)
      assert_not_nil(kase.status)
      assert_not_nil(kase.supplier_id)
      assert_not_nil(kase.enroller_id)
      assert_not_nil(kase.account)
      assert_not_nil(kase.recipient)

      recipient = kase.recipient
      assert_not_nil(recipient.record)
      assert_not_nil(recipient.id)
      assert_not_nil(recipient.profile)
      assert_not_nil(recipient.dhs_account)
    end
  end
end
