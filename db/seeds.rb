if Rails.env.development?
  return
end

require "seeds/create_organizations"
require "seeds/create_chat_macros"
