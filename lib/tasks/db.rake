namespace :db do
  namespace :seed do
    desc "Loads development seeds"
    task dev: :environment do
      require "seeds/create_chat_macros"
    end
  end
end
