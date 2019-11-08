class CasesMailer < ApplicationMailer
  def did_open(case_id)
    @case = Case::Repo.get.find(case_id)

    emails = User::Repo.get
      .find_all_for_opened_case
      .map(&:email)

    mail(
      subject: "Cohere Pilot -- A new case was opened!",
      bcc: emails
    )
  end

  def did_submit(case_id)
    @case = Case::Repo.get.find(case_id)

    emails = User::Repo.get
      .find_all_for_submitted_case(@case)
      .map(&:email)

    mail(
      subject: "Cohere Pilot -- A case was submitted!",
      bcc: emails
    )
  end
end
