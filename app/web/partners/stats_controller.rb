module Partners
  class StatsController < ApplicationController
    http_basic_authenticate_with(
      name: ENV["STATS_AUTH_NAME"],
      password: ENV["STATS_AUTH_PASSWORD"],
    )

    def show
      @stats = Stats::Repo.get.find_current
    end
  end
end
