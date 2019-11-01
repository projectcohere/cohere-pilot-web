class ApplicationMailer < ActionMailer::Base
  layout("mailer")
  default(from: ENV["SEND_AS_EMAIL"])
end
