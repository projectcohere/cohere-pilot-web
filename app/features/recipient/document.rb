class Recipient
  class Document < ::Entity
    # -- props --
    prop(:id)
    prop(:url)
    prop(:source_url)

    # -- lifetime --
    def initialize(id: nil, url: nil, source_url:)
      @id = id
      @url = url
      @source_url = source_url
    end

    # -- events --
    def did_save(id)
      @id = id
    end
  end
end
