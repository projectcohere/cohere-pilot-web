module Cases
  class Mailer < ApplicationMailer
    def did_open(case_id)
      @case = view_repo.find_notification(case_id)

      mail(
        subject: "Cohere Pilot -- A new case was opened!",
        bcc: user_repo.find_emails_for_opened_case,
      )
    end

    def did_submit(case_id)
      @case = view_repo.find_notification(case_id)

      mail(
        subject: "Cohere Pilot -- A case was submitted!",
        bcc: user_repo.find_emails_for_submitted_case(@case),
      )
    end

    def did_complete(case_id)
      @case = view_repo.find_notification(case_id)

      mail(
        subject: "Cohere Pilot -- A case was completed!",
        bcc: user_repo.find_emails_for_completed_case,
      )
    end

    # -- queries --
    private def view_repo
      return Cases::Views::Repo.get(nil)
    end

    private def user_repo
      return User::Repo.get
    end
  end
end
