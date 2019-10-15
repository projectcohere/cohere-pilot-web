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

  def inbound
    if policy.permit?(:list)
      redirect_to(cases_path)
    end
  end

  def show
    user = Current.user
    repo = Case::Repo.new

    @case = case user.role
    when :cohere
      repo.find_one(params[:id])
    when :enroller
      repo.find_one_for_enroller(params[:id], user.organization.id)
    end

    if policy(@case).forbid?(:show)
      deny_access
    end
  end

  def new
    if policy.forbid?(:create)
      deny_access
    end

    @case = Case::Inbound.new
  end

  def create
    if policy.forbid?(:create)
      deny_access
    end

    attrs = params.require(:case).permit(Case::Inbound.attribute_names)
    @case = Case::Inbound.new(attrs)

    # we require that the user be a supplier right now
    supplier = Current.user.organization

    # and add every case to the default enroller
    enroller = Enroller::Repo.new.find_default

    # then create the new case
    factory = Case::Factory.new
    factory.create_inbound(@case, supplier.id, enroller.id)
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
