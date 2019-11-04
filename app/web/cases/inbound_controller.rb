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

      # TODO: make form form responsible for fetching
      # this information
      # require that the user be a supplier right now
      supplier = Current.user.organization
      # and add every case to the default enroller
      enroller = Enroller::Repo.new.find_default

      # render errors if form failed to save
      if not @form.save(supplier.id, enroller.id)
        flash.now[:alert] = "Please check the case for errors."
        render(:new)
        return
      end

      note = Case::Notes::OpenedCase::Broadcast.new
      note.receiver_ids.each do |receiver_id|
        InboundMailer.opened_case(@form.case_id, receiver_id).deliver_later
      end

      redirect_to(cases_inbound_index_path, notice: "Created case!")
    end

    # -- commands --
    private def check_scope
      if not case_scope.scoped?
        deny_access
      end
    end

    # -- queries --
    private def policy
      case_scope.policy
    end

    def case_scope
      @case_scope ||= CaseScope.new(:inbound, Current.user)
    end
  end
end
