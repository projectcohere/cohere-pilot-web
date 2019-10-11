class CasesController < ApplicationController
  def index
    return if policy.forbid?(:list)

    user = Current.user
    repo = Case::Repo.new

    @cases = case user.role
    when :cohere
      repo.find_incomplete
    when :enroller
      repo.find_pending_for_enroller(user.organization.id)
    end
  end

  private

  def policy(kase = nil)
    Case::Policy.new(Current.user, kase)
  end
end
