module Cases
  class InboundController < ApplicationController
    # -- filters --
    before_action(:check_scope)

    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        deny_access
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
        redirect_to(cases_inbound_index_path)
      else
        render(:new)
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
        kase,
        scope: :inbound
      )
    end
  end
end
