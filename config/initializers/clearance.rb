Clearance.configure do |config|
  config.routes = false
  config.allow_sign_up = false
  config.rotate_csrf_on_sign_in = true
  config.user_model = "::User::Record"
end
