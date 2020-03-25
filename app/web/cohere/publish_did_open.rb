module Cohere
  class PublishDidOpen < ApplicationWorker
    # -- command --
    def call(case_id)
      kase = Case::Repo.get.find(case_id)

      # render cell from case
      view = Cases::View.new(kase, Cases::Scope::Queued)
      html = renderer.render(partial: "cohere/cases/cell",
        layout: nil,
        object: view
      )

      # publish event to cohere users
      event = Cases::ActivityEvent

      Cases::ActivityChannel.broadcast_to(
        Partner::Repo.get.find_cohere.id,
        event.new(
          name: event::AddCaseToQueue,
          data: event::NewCase.new(
            case_id: kase.id.val,
            case_html: html
          ),
        )
      )
    end

    alias :perform :call

    # -- command/helpers
    private def renderer
      return CasesController.renderer
    end
  end
end
