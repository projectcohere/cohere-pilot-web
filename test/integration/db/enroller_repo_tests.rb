require "test_helper"

module Db
  class PartnerRepoTests < ActiveSupport::TestCase
    # -- queries --
    # -- queries/one
    test "finds a partner" do
      partner_repo = Partner::Repo.new
      partner_id = partners(:enroller_1).id

      partner = partner_repo.find(partner_id)
      assert_not_nil(partner)
      assert_equal(partner.id, partner_id)
    end

    test "finds the default enroller" do
      partner_repo = Partner::Repo.new

      partner = partner_repo.find_default_enroller
      assert_not_nil(partner)
      assert_equal(partner.membership_class, Partner::MembershipClass::Enroller)
      assert_equal(partner, partner_repo.find_default_enroller)
    end

    # -- queries/many
    test "finds many partners" do
      partner_repo = Partner::Repo.new
      partner_ids = [
        partners(:enroller_1).id,
        partners(:enroller_2).id
      ]

      partners = partner_repo.find_many(partner_ids)
      assert_length(partners, 2)
      assert_same_elements(partners.map(&:id), partner_ids)
    end
  end
end
