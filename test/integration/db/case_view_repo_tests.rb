require "test_helper"

module Db
  class CaseViewRepoTests < ActiveSupport::TestCase
    def stub_user(name)
      User::Repo.get.sign_in(users(name))
    end

    # -- queries --
    # -- queries/supplier
    test "finds a page of cases for a supplier" do
      stub_user(:supplier_1)
      case_repo = Cases::ViewRepo.new(Cases::Scope::All)

      case_page, cases = case_repo.find_all_for_search(page: 1)
      assert_length(cases, 7)
      assert_equal(case_page.count, 7)
      assert(cases.any? { |c| c.assignee_email != nil })
    end

    # -- queries/governor
    test "finds a page of assigned cases for a governor user" do
      stub_user(:governor_1)
      case_repo = Cases::ViewRepo.new(nil)

      case_page, cases = case_repo.find_all_assigned(page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
    end

    test "finds a page of queued cases for a governor user" do
      stub_user(:governor_1)
      case_repo = Cases::ViewRepo.new(nil)

      case_page, cases = case_repo.find_all_queued(page: 1)
      assert_length(cases, 4)
      assert_equal(case_page.count, 4)
    end

    test "finds a page of cases for a governor user" do
      stub_user(:governor_1)
      case_repo = Cases::ViewRepo.new(Cases::Scope::All)

      case_page, cases = case_repo.find_all_for_search(page: 1)
      assert_length(cases, 5)
      assert_equal(case_page.count, 5)
      assert(cases.any? { |c| c.assignee_email != nil })
    end

    # -- queries/cohere
    test "finds a page of assigned cases for a cohere user" do
      stub_user(:cohere_1)
      case_repo = Cases::ViewRepo.new(nil)

      case_page, cases = case_repo.find_all_assigned(page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
    end

    test "finds a page of queued cases for a cohere user" do
      stub_user(:cohere_1)
      case_repo = Cases::ViewRepo.new(nil)

      case_page, cases = case_repo.find_all_queued(page: 1)
      assert_length(cases, 7)
      assert_equal(case_page.count, 7)
    end

    test "finds a page of cases by recipient name for a cohere user" do
      stub_user(:cohere_1)
      case_repo = Cases::ViewRepo.new(Cases::Scope::All)

      case_page, cases = case_repo.find_all_for_search("Johnice", page: 1)
      assert_length(cases, 5)
      assert_equal(case_page.count, 5)
    end

    test "finds a page of cases by phone number for a cohere user" do
      stub_user(:cohere_1)
      case_repo = Cases::ViewRepo.new(Cases::Scope::All)

      case_page, cases = case_repo.find_all_for_search("+1 (444) 555-6666", page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
    end

    test "finds a page of open cases for a cohere user" do
      stub_user(:cohere_1)
      case_repo = Cases::ViewRepo.new(Cases::Scope::Open)

      case_page, cases = case_repo.find_all_for_search(page: 1)
      assert_length(cases, 8)
      assert_equal(case_page.count, 8)
      assert(cases.any? { |c| c.assignee_email != nil })
    end

    test "finds a page of completed cases for a cohere user" do
      stub_user(:cohere_1)
      case_repo = Cases::ViewRepo.new(Cases::Scope::Completed)

      case_page, cases = case_repo.find_all_for_search(page: 1)
      assert_length(cases, 2)
      assert_equal(case_page.count, 2)
      assert(cases.any? { |c| c.assignee_email != nil })
    end

    # -- queries/enroller
    test "finds a page of assigned cases for an enroller" do
      stub_user(:enroller_1)
      case_repo = Cases::ViewRepo.new(nil)

      case_page, cases = case_repo.find_all_assigned(page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
    end

    test "finds a page of queued cases for an enroller" do
      stub_user(:enroller_1)
      case_repo = Cases::ViewRepo.new(nil)

      case_page, cases = case_repo.find_all_queued(page: 1)
      assert_length(cases, 0)
      assert_equal(case_page.count, 0)
    end

    test "finds a page of cases by recipient name for an enroller" do
      stub_user(:enroller_1)
      case_repo = Cases::ViewRepo.new(Cases::Scope::All)

      case_page, cases = case_repo.find_all_for_search("Johnice", page: 1)
      assert_length(cases, 2)
      assert_equal(case_page.count, 2)
    end

    test "finds a page of cases by phone number for an enroller" do
      stub_user(:enroller_1)
      case_repo = Cases::ViewRepo.new(Cases::Scope::All)

      case_page, cases = case_repo.find_all_for_search("+1 (333) 444-5555", page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
    end
  end
end
