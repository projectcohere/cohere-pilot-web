namespace :db do
  namespace :seed do
    desc "Loads development seeds"
    task dev: :environment do
      require "seeds/create_test_files"
      require "seeds/create_chat_macros"
    end

    desc "Reloads staging seeds"
    task staging: :environment do
      require "seeds/create_programs_partners"
      require "seeds/create_users"
      require "seeds/create_chat_macros"
    end
  end
end
