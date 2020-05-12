module Agent
  class NotesController < Cases::BaseController
    def create
      permit!(:create_note)

      Cases::AddNote.(
        params[:case_id],
        params.dig(:case_note, :body),
      )
    end
  end
end
