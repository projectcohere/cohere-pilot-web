module DemoHelper
  def demo?
    return @demo
  end

  # -- helpers --
  def params
    @params || super
  end

  def signed_in?
    return user != nil
  end
end
