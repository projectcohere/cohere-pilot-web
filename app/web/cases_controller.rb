class CasesController < ApplicationController
  # -- filters --
  before_action(:check_scope)

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

  def edit
    user = Current.user
    repo = Case::Repo.new

    @form = case user.role
    when :cohere
      kase = repo.find_one(params[:id])
      Case::Forms::Full.new(kase)
    when :enroller
      kase = repo.find_one_for_enroller(params[:id], user.organization.id)
      Case::Forms::Full.new(kase)
    end

    if @form.nil? || policy(@form.model).forbid?(:edit)
      deny_access
    end
  end

  def update
    user = Current.user
    repo = Case::Repo.new

    @form = case user.role
    when :cohere
      kase = repo.find_one(params[:id])
      Case::Forms::Full.new(kase)
    when :enroller
      kase = repo.find_one_for_enroller(params[:id], user.organization.id)
      Case::Forms::Full.new(kase)
    end

    if @form.nil? || policy(@form.model).forbid?(:edit)
      deny_access
    end

    if @form.save
      redirect_to(cases_path)
    else
      render(:edit)
    end
  end

  private

  # -- commands --
  def check_scope
    if policy.forbid?(:some)
      deny_access
    end
  end

  # -- queries --
  def policy(kase = nil)
    @policy ||= Case::Policy.new(
      Current.user,
      kase
    )
  end
end
