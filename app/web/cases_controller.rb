class CasesController < ApplicationController
  # -- helpers --
  helper_method(:policy)

  # -- actions --
  def index
    if policy.forbid?(:list)
      deny_access
    end

    user = Current.user
    repo = Case::Repo.new

    @cases = case user.role
    when :cohere
      repo.find_incomplete
    when :enroller
      repo.find_for_enroller(user.organization.id)
    end
  end

  def show
    user = Current.user
    repo = Case::Repo.new

    case_id = params[:id]
    kase = case user.role
    when :cohere
      repo.find_one(case_id)
    when :enroller
      repo.find_one_for_enroller(case_id, user.organization.id)
    end

    if policy(kase).forbid?(:show)
      deny_access
    end

    @case = kase
  end

  def inbound
    if policy.permit?(:list)
      redirect_to(cases_path)
    end
  end

  private

  # -- queries --
  def policy(kase = nil)
    @policy ||= Case::Policy.new(
      Current.user,
      kase
    )
  end
end
