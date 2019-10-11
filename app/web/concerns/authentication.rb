module Authentication
  extend ActiveSupport::Concern

  included do
    before_action(:build_user)
  end

  private

  # builds a user entity from the current_user record fetched
  # by clearance
  def build_user
    if current_user != nil
      Current.user = User::from_record(current_user)
    end
  end
end

# module Clearance
#   class Session
#     sign_in = instance_method(:sign_in)

#     define_method(:sign_in) do |*args|
#       # binding.pry
#       sign_in.bind(self).(*args)
#     end
#   end
# end
