class FileData
  # -- props --
  attr_reader(:data)
  attr_reader(:mime_type)

  # -- lifetime --
  def initialize(data:, name:, mime_type:)
    @data = data
    @name = name
    @mime_type = mime_type
  end

  # -- queries --
  def name
    if @name.is_a?(Proc)
      return @name.(@data)
    end

    @name
  end
end
