class CasesController < ApplicationController
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

    kase_id = params[:id]
    kase = case user.role
    when :cohere
      repo.find_one(kase_id)
    when :enroller
      repo.find_one_for_enroller(kase_id, user.organization.id)
    end

    if policy(kase).forbid?(:show)
      deny_access
    end

    @case = kase
  end

  private

  def policy(kase = nil)
    @policy ||= Case::Policy.new(Current.user, kase)
  end
end
