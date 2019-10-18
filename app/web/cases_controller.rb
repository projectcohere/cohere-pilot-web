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
    when :dhs
      repo.find_opened
    end
  end

  def inbound
    if policy.permit?(:list)
      redirect_to(cases_path)
    end
  end

  def new
    if policy.forbid?(:create)
      deny_access
    end

    @form = Case::Forms::Inbound.new
  end

  def create
    if policy.forbid?(:create)
      deny_access
    end

    @form = Case::Forms::Inbound.new(
      params
        .require(:case)
        .permit(Case::Forms::Inbound.attribute_names)
    )

    # require that the user be a supplier right now
    supplier = Current.user.organization
    # and add every case to the default enroller
    enroller = Enroller::Repo.new.find_default

    if @form.save(supplier.id, enroller.id)
      redirect_to(inbound_cases_path)
    else
      render(:new)
    end
  end

  def edit
    user = Current.user
    repo = Case::Repo.new

    @form = case user.role
    when :cohere
      kase = repo.find_one(params[:id])
      Case::Forms::Household.new(kase) # TODO: use the Full form
    when :enroller
      kase = repo.find_one_for_enroller(params[:id], user.organization.id)
      Case::Forms::Household.new(kase) # TODO: use the Full form
    when :dhs
      kase = repo.find_one_opened(params[:id])
      Case::Forms::Household.new(kase)
    end

    if @form == nil || policy(@form.case).forbid?(:edit)
      deny_access
    end
  end

  def update
    user = Current.user
    repo = Case::Repo.new

    @form = case user.role
    when :cohere
      kase = repo.find_one(params[:id])
      Case::Forms::Household.new(kase) # TODO: use the Full form
    when :enroller
      kase = repo.find_one_for_enroller(params[:id], user.organization.id)
      Case::Forms::Household.new(kase) # TODO: use the Full form
    when :dhs
      kase = repo.find_one_opened(params[:id])
      Case::Forms::Household.new(kase,
        params
          .require(:case)
          .permit(Case::Forms::Household.params_shape)
      )
    end

    if @form == nil || policy(@form.case).forbid?(:edit)
      deny_access
    end

    if @form.save
      redirect_to(cases_path)
    else
      render(:edit)
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
