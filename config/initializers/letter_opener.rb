if not Rails.env.development?
  return
end

LetterOpener.configure do |config|
  config.location = Rails.root.join("tmp", "mail")
end
