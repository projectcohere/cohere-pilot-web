namespace :macros do
  namespace :update do
    desc "Updates macros"
    task dev: :environment do
      require "seeds/create_chat_macros"
    end
  end
end
