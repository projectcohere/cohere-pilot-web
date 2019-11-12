class Document < ::Entity
  prop(:record, default: nil)

  # -- props --
  prop(:id, default: nil)
  prop(:classification)
  prop(:file, default: nil)
  prop(:source_url, default: nil)
  props_end!

  # -- props/temp
  attr(:new_file)

  # -- lifetime
  def self.upload(source_url)
    Document.new(
      classification: :unclassified,
      source_url: source_url
    )
  end

  def self.sign_contract
    Document.new(
      classification: :contract,
    )
  end

  # -- commands --
  def attach_file(file)
    @new_file = file
  end

  # -- callbacks --
  def did_save(record)
    @record = record
    @id = record.id
  end
end
