class CasesMailer < ApplicationMailer
  # -- helpers --
  helper_method(:case_scope)

  # -- actions --
  def opened_case(case_id, user_id)
    @note = Case::Notes::OpenedCase.new(case_id, user_id)

    mail(
      subject: @note.title,
      to: @note.receiver_email
    )
  end

  def submitted_case(case_id, user_id)
    @note = Case::Notes::SubmittedCase.new(case_id, user_id)

    mail(
      subject: @note.title,
      to: @note.receiver_email
    )
  end

  # -- queries --
  private def case_scope
    @case_scope ||= CaseScope.new(:root, @note.receiver)
  end
end
