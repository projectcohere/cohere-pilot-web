namespace :stats do
  desc "Process stats from a case events csv"
  task "process-case-events": :environment do
    Partners::Stats::ProcessCaseEvents.($stdin)
  end
end
