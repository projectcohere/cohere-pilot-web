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

      @form = Case::Forms::Inbound.new(nil,
        params
          .require(:case)
          .permit(Case::Forms::Inbound.attribute_names)
      )

      # require that the user be a supplier right now
      supplier = Current.user.organization
      # and add every case to the default enroller
      enroller = Enroller::Repo.new.find_default

      if @form.save(supplier.id, enroller.id)
        redirect_to(cases_inbound_index_path, notice: "Created case!")
      else
        flash.now[:alert] = "Please check the case for errors."
        render(:new)
      end
    end

    # -- commands --
    private def check_scope
      if policy.forbid?(:some)
        deny_access
      end
    end

    # -- queries --
    private def policy(kase = nil)
      @policy ||= Case::Policy.new(
        Current.user,
        kase,
        scope: :inbound
      )
    end
  end
end
