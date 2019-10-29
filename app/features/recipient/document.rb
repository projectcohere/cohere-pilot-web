class Recipient
  class Document < ::Entity
    attr_reader(:record)

    # -- props --
    prop(:id)
    prop(:url)
    prop(:source_url)

    # -- props/temp
    prop(:new_file)

    # -- lifetime --
    def initialize(record: nil, id: nil, url: nil, source_url:)
      @record = record
      @id = id
      @url = url
      @source_url = source_url
    end

    # -- commands --
    def attach_file(file)
      @new_file = file
    end

    # -- events --
    def did_save(record)
      @record = record
      @id = record.id
    end

    # -- factories --
    def self.from_record(r)
      Document.new(
        record: r,
        id: r.id,
        url: nil,
        source_url: r.source_url
      )
    end
  end
end
