# -- types --
Macro = Struct.new(:path, :filename)

# -- main --
macros = Rails.root.join("macros")
  .children
  .filter { |p| p.extname == ".png" }
  .map { |p| Macro.new(p, p.basename.to_s) }

created = ActiveStorage::Blob
  .where(filename: [macros.map(&:filename)])
  .pluck(:filename)

macros.each do |m|
  if not created.include?(m.filename)
    ActiveStorage::Blob.create_and_upload!(
      io: File.new(m.path),
      filename: m.filename,
      content_type: "image/png",
    )
  end
end
