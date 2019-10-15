class Enroller
  class Repo
    # -- queries --
    # -- queries/one
    def find_default
      record = Enroller::Record.first
      Enroller.from_record(record)
    end
  end
end
