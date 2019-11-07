class CasesMailer < ApplicationMailer
  # -- actions --
  def did_open(case_id)
    @case = Case::Repo.get.find(case_id)

    emails = User::Repo.get
      .find_all_opened_case_contributors
      .map(&:email)

    mail(
      subject: "Cohere Pilot -- A new case was opened!",
      bcc: emails
    )
  end

  def did_submit(case_id)
    @case = Case::Repo.get.find(case_id)

    emails = User::Repo.get
      .find_all_submitted_case_contributors(@case.enroller_id)
      .map(&:email)

    mail(
      subject: "Cohere Pilot -- A case was submitted!",
      bcc: emails
    )
  end
end
