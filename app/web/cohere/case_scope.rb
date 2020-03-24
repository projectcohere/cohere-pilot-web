module Cohere
  class CaseScope < ::Value
    # -- props --
    prop(:path)

    # -- queries --
    def name
      return case self
      when Queued
        "Queued"
      when Open
        "Open"
      when Completed
        "Completed"
      end
    end

    def queued?
      return self == Queued
    end

    def opened?
      return self == Opened
    end

    def completed?
      return self == Completed
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
