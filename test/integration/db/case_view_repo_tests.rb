require "test_helper"

module Db
  class CaseViewRepoTests < ActiveSupport::TestCase
    test "finds a page of assigned cases" do
      case_repo = Cases::ViewRepo.new(nil)
      user_rec = users(:cohere_1)

      case_page, cases = case_repo.find_all_assigned_to_user(Id.new(user_rec.id), page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
    end

    test "finds a page of queued cases for a cohere user" do
      case_repo = Cases::ViewRepo.new(nil)
      user_rec = users(:cohere_1)

      case_page, cases = case_repo.find_all_queued_for_cohere(user_rec.partner_id, page: 1)
      assert_length(cases, 7)
      assert_equal(case_page.count, 7)
    end

    test "finds a page of cases by recipient name" do
      case_repo = Cases::ViewRepo.new(Cases::Scope::All)
      user_rec = users(:cohere_1)

      case_page, cases = case_repo.find_all_for_search("john", user_rec.partner_id, page: 1)
      assert_length(cases, 5)
      assert_equal(case_page.count, 5)
    end

    test "finds a page of open cases for a cohere user" do
      case_repo = Cases::ViewRepo.new(Cases::Scope::Open)
      user_rec = users(:cohere_1)

      case_page, cases = case_repo.find_all_for_search("", user_rec.partner_id, page: 1)
      assert_length(cases, 8)
      assert_equal(case_page.count, 8)
      assert(cases.any? { |c| c.assignee_email != nil })
    end

    test "finds a page of completed cases for a cohere user" do
      case_repo = Cases::ViewRepo.new(Cases::Scope::Completed)
      user_rec = users(:cohere_1)

      case_page, cases = case_repo.find_all_for_search("", user_rec.partner_id, page: 1)
      assert_length(cases, 2)
      assert_equal(case_page.count, 2)
      assert(cases.any? { |c| c.assignee_email != nil })
    end
  end
end
