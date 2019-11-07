class Document < ::Entity
  prop(:record, default: nil)

  # -- props --
  prop(:id, default: nil)
  prop(:file, default: nil)
  prop(:case_id)
  prop(:source_url)
  props_end!

  # -- props/temp
  attr(:new_file)

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
