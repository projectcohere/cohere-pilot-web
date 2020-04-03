class Document < ::Entity
  prop(:record, default: nil)

  # -- props --
  prop(:id, default: Id::None)
  prop(:classification)
  prop(:file, default: nil)
  prop(:source_url, default: nil)

  # -- props/temp
  attr(:new_file)

  # -- lifetime
  def self.attach_file(new_file)
    document = Document.new(classification: :unknown)
    document.attach_file(new_file)
    return document
  end

  def self.sign_contract(program_contract)
    return Document.new(
      classification: :contract,
      source_url: program_contract.variant.to_s
    )
  end

  def self.copy(document)
    return Document.new(
      classification: document.classification,
      file: document.file,
      source_url: document.source_url
    )
  end

  # -- commands --
  def attach_file(new_file)
    @new_file = new_file
  end

  # -- callbacks --
  def did_save(record)
    @id.set(record.id)
    @record = record
  end
end
