class Document < ::Entity
  prop(:record, default: nil)

  # -- props --
  prop(:id, default: nil)
  prop(:classification)
  prop(:file, default: nil)
  prop(:case_id)
  prop(:source_url, default: nil)
  props_end!

  # -- props/temp
  attr(:new_file)

  # -- lifetime
  def self.upload(source_url, case_id:)
    Document.new(
      classification: :unclassified,
      case_id: case_id,
      source_url: source_url
    )
  end

  def self.generate_contract(case_id:)
    Document.new(
      classification: :contract,
      case_id: case_id
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
