module Cases
  class Scope
    include ::Options

    # -- options --
    option("queued")
    option("assigned")
    option("open")
    option("completed")

    # -- queries --
    def path
      return @key
    end

    def name
      return @key.capitalize
    end
  end
end
