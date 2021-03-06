module Minitest
  def self.plugin_failures_init(options)
    reporter.reporters << Failures.new
  end

  class Failures < Reporter
    def initialize(
      proj_path: "cohere-pilot-web/",
      file_path: "tmp/failures.log"
    )
      # options
      @proj_path = proj_path
      @file_path = file_path

      # props
      @total = 0
      @failures = []
    end

    # -- Reporter --
    def record(result)
      @total += 1

      if result.failure != nil && !result.skipped?
        @failures << result
      end
    end

    def report
      # don't clobber failures when running a single test
      if @total <= 1
        return
      end

      # write failures to disk
      File.open(@file_path, "w+") do |file|
        failure_locations = @failures.map do |failure|
          path, line = failure.source_location
          path = path.split(@proj_path).last
          file.puts("#{path}:#{line}")
        end
      end
    end
  end
end

# configure minitest to call "Minitest.plugin_failures_init"
Minitest.extensions << "failures"
