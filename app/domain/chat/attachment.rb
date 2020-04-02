class Chat
  class Attachment < ::Entity
    # -- props --
    prop(:record, default: nil)
    prop(:id, default: Id::None)
    prop(:file, default: nil)
    prop(:remote_url, default: nil)

    # -- props/temporary
    attr(:uploaded_url)

    # -- lifetime --
    def self.from_source(source)
      if source.respond_to?(:url)
        return Attachment.new(remote_url: source.url)
      else
        return Attachment.new(file: source)
      end
    end

    # -- commands --
    def upload(file)
      @file = file
      @uploaded_url = @remote_url
      @remote_url = nil
    end

    # -- queries --
    def remote?
      return @remote_url != nil
    end

    # -- events --
    def did_save(record)
      @id.set(record.id)
      @record = record
    end
  end
end
