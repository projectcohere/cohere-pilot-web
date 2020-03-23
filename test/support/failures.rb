module Minitest
  def self.plugin_failures_init(options)
    reporter.reporters << Failures.new
  end

  class Failures < Reporter
    def initialize(
      proj_path: "cohere-pilot-web/",
      file_path: "tmp/failures.log"
    )
      @proj_path = proj_path
      @file_path = file_path
    end

    # -- Reporter --
    def record(result)
      if result.error?
        failures << result
      end
    end

    def report
      File.open(@file_path, "w+") do |file|
        failure_locations = failures.map do |failure|
          path, line = failure.source_location
          path = path.split(@proj_path).last
          file.puts("#{path}:#{line}")
        end
      end
    end

    # -- queries --
    private def failures
      @failures ||= []
    end
  end
end

# configure minitest to call "Minitest.plugin_failures_init"
Minitest.extensions << "failures"
