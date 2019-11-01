class ApplicationMailer < ActionMailer::Base
  layout("mailer")
  default(from: ENV["MAILERS_SEND_AS"])
end
