module Cohere
  class CaseScope < ::Value
    # -- props --
    prop(:path)

    # -- queries --
    def name
      return case self
      when Open
        "Open"
      when Queued
        "Queued"
      when Completed
        "Completed"
      end
    end

    # -- options --
    def self.option(path)
      return CaseScope.new(path: path).freeze
    end

    Queued = option("queued")
    Open = option("open")
    Completed = option("completed")

    # -- factories --
    def self.from_path(path)
      return case path
      when "queued"
        Queued
      when "open"
        Open
      when "completed"
        Completed
      end
    end
  end
end
