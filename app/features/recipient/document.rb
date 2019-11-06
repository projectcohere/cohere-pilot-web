class Recipient
  class Document < ::Entity
    prop(:record, default: nil)

    # -- props --
    prop(:id, default: nil)
    prop(:file, default: nil)
    prop(:source_url)
    props_end!

    # -- props/temp
    attr(:new_file)

    # -- lifetime --
    def initialize(record: nil, id: nil, file: nil, source_url:)
      @record = record
      @id = id
      @file = file
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
  end
end
