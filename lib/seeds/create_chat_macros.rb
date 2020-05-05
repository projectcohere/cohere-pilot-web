macros = Rails.root.join("macros")
  .children
  .filter { |p| p.extname == ".png" }

macros.each do |path|
  ActiveStorage::Blob.create_and_upload!(
    io: File.new(path),
    filename: path.basename.to_s,
    content_type: "image/png",
  )
end
