# -- types --
Macro = Struct.new(:path, :filename)

# -- main --
macros = Rails.root.join("macros")
  .children
  .filter { |p| p.extname == ".png" }
  .map { |p| Macro.new(p, p.basename.to_s) }

# destroy old blobs, we're going to replace them
created = ActiveStorage::Blob
  .where(filename: [macros.map(&:filename)])
  .destroy_all

# create new blobs for every macro
macros.each do |m|
  ActiveStorage::Blob.create_and_upload!(
    io: File.new(m.path),
    filename: m.filename,
    content_type: "image/png",
  )
end
