module Cohere
  class CaseScope < ::Value
    # -- props --
    prop(:path)

    # -- queries --
    def name
      return case self
      when Queue
        "Open"
      when Completed
        "Completed"
      end
    end

    # -- options --
    def self.option(path)
      return CaseScope.new(path: path).freeze
    end

    Queue = option("queue")
    Completed = option("completed")

    # -- factories --
    def self.from_path(path)
      return case path
      when "queue"
        Queue
      when "completed"
        Completed
      end
    end
  end
end
