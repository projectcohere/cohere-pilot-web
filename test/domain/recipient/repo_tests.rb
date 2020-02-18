require "test_helper"

module Recipient
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      recipient_rec = recipients(:recipient_2)

      profile = ::Recipient::Repo.map_profile(recipient_rec)
      assert_not_nil(profile)

      phone = profile.phone
      assert_not_nil(phone.number)

      name = profile.name
      assert_not_nil(name.first)
      assert_not_nil(name.last)

      address = profile.address
      assert_not_nil(address.street)
      assert_not_nil(address.street2)
      assert_not_nil(address.city)
      assert_not_nil(address.state)
      assert_not_nil(address.zip)

      dhs_account = ::Recipient::Repo.map_dhs_account(recipient_rec)
      assert_not_nil(dhs_account.number)

      household = dhs_account.household
      assert_not_nil(household.size)
      assert_not_nil(household.income_cents)
      assert_not_nil(household.ownership)
      assert_not_nil(household.is_primary_residence)
    end
  end
end
