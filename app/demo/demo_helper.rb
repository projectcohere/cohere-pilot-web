module DemoHelper
  # def user
  #   return @user
  # end

  def signed_in?
    return user != nil
  end
end
