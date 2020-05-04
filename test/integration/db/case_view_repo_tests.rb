require "test_helper"

module Db
  class CaseViewRepoTests < ActiveSupport::TestCase
    def stub_user(name)
      User::Repo.get.sign_in(users(name))
    end

    # -- queries --
    # -- queries/source
    test "finds a page of cases for a source" do
      stub_user(:source_1)
      case_repo = Cases::Views::Repo.new(Cases::Scope::All)

      case_page, cases = case_repo.find_all_for_search(page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
      assert(cases.all? { |c| c.assignee_email != nil })
    end

    # -- queries/governor
    test "finds a page of assigned cases for a governor" do
      stub_user(:governor_1)
      case_repo = Cases::Views::Repo.new(nil)

      case_page, cases = case_repo.find_all_assigned(page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
    end

    test "finds a page of queued cases for a governor" do
      stub_user(:governor_1)
      case_repo = Cases::Views::Repo.new(nil)

      case_page, cases = case_repo.find_all_queued(page: 1)
      assert_length(cases, 4)
      assert_equal(case_page.count, 4)
    end

    test "finds a page of cases for a governor" do
      stub_user(:governor_1)
      case_repo = Cases::Views::Repo.new(Cases::Scope::All)

      case_page, cases = case_repo.find_all_for_search(page: 1)
      assert_length(cases, 5)
      assert_equal(case_page.count, 5)
      assert(cases.any? { |c| c.assignee_email != nil })
    end

    # -- queries/agent
    test "finds a page of assigned cases for an agent" do
      stub_user(:agent_1)
      case_repo = Cases::Views::Repo.new(nil)

      case_page, cases = case_repo.find_all_assigned(page: 1)
      assert_length(cases, 2)
      assert_equal(case_page.count, 2)
    end

    test "finds a page of queued cases for an agent" do
      stub_user(:agent_1)
      case_repo = Cases::Views::Repo.new(nil)

      case_page, cases = case_repo.find_all_queued(page: 1)
      assert_length(cases, 8)
      assert_equal(case_page.count, 8)
    end

    test "finds a page of cases by recipient name for an agent" do
      stub_user(:agent_1)
      case_repo = Cases::Views::Repo.new(Cases::Scope::All)

      case_page, cases = case_repo.find_all_for_search("Johnice", page: 1)
      assert_length(cases, 6)
      assert_equal(case_page.count, 6)
    end

    test "finds a page of cases by phone number for an agent" do
      stub_user(:agent_1)
      case_repo = Cases::Views::Repo.new(Cases::Scope::All)

      case_page, cases = case_repo.find_all_for_search("+1 (444) 555-6666", page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
    end

    test "finds a page of active cases for an agent" do
      stub_user(:agent_1)
      case_repo = Cases::Views::Repo.new(Cases::Scope::Active)

      case_page, cases = case_repo.find_all_for_search(page: 1)
      assert_length(cases, 10)
      assert_equal(case_page.count, 10)
      assert(cases.any? { |c| c.assignee_email != nil })
    end

    test "finds a page of archived cases for an agent" do
      stub_user(:agent_1)
      case_repo = Cases::Views::Repo.new(Cases::Scope::Archived)

      case_page, cases = case_repo.find_all_for_search(page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
      assert(cases.any? { |c| c.assignee_email != nil })
    end

    # -- queries/enroller
    test "finds a page of assigned cases for an enroller" do
      stub_user(:enroller_1)
      case_repo = Cases::Views::Repo.new(nil)

      case_page, cases = case_repo.find_all_assigned(page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
    end

    test "finds a page of queued cases for an enroller" do
      stub_user(:enroller_1)
      case_repo = Cases::Views::Repo.new(nil)

      case_page, cases = case_repo.find_all_queued(page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
    end

    test "finds a page of cases by recipient name for an enroller" do
      stub_user(:enroller_1)
      case_repo = Cases::Views::Repo.new(Cases::Scope::All)

      case_page, cases = case_repo.find_all_for_search("Johnice", page: 1)
      assert_length(cases, 2)
      assert_equal(case_page.count, 2)
    end

    test "finds a page of cases by phone number for an enroller" do
      stub_user(:enroller_1)
      case_repo = Cases::Views::Repo.new(Cases::Scope::All)

      case_page, cases = case_repo.find_all_for_search("+1 (333) 444-5555", page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
    end
  end
end
