namespace :data do
  namespace :migrate do
    desc "Runs data migrations for Program & Partner support."
    task partners: :environment do
      require "migrate/create_partners"
    end
  end
end
