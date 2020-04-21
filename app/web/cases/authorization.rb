module Cases
  module Authorization
    extend ActiveSupport::Concern

    # -- includes --
    include ::Authorization

    # -- queries --
    def policy
      return Case::Policy.new(user, @case)
    end
  end
end
