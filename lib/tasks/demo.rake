namespace :demo do
  desc "Builds the demos site"
  task build: :environment do
    BuildDemoSite.()
  end
end
