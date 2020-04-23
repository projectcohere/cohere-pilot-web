if Rails.env.development?
  return
end

require "seeds/create_programs_partners"
require "seeds/create_chat_macros"
