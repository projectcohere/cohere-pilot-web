class Enroller
  class SaveCompletedCase
    def initialize(kase, action, case_repo: Case::Repo.get)
      @case_repo = case_repo
      @case = kase
      @action = action
    end

    def call
      # determine status
      status = case @action
      when :approve
        Case::Status::Approved
      when :deny
        Case::Status::Denied
      end

      # complete the case
      @case.complete(status)
      @case_repo.save_completed(@case)
    end
  end
end
