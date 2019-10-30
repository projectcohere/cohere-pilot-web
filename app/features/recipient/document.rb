class Recipient
  class Document < ::Entity
    prop(:record, default: nil)

    # -- props --
    prop(:id, default: nil)
    prop(:url, default: nil)
    prop(:source_url)
    props_end!

    # -- props/temp
    attr(:new_file)

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
