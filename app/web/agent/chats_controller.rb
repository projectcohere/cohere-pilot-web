module Agent
  class ChatsController < ApplicationController
    def files
      @chat = Chat::Repo.get.find(params[:chat_id])
      if policy.forbid?(:files)
        return head(:not_found)
      end

      file_ids = File::Repo.get
        .save_uploaded_files(params[:files].values)

      render(json: {
        "data" => {
          "fileIds" => file_ids
        }
      })
    rescue ActiveRecord::RecordNotFound
      return head(:not_found)
    end

    # -- queries --
    private def policy
      Chat::Policy.new(User::Repo.get.find_current, @chat)
    end
  end
end
