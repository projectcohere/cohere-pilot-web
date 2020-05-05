macros = Rails.root.join("macros")
  .children
  .filter { |p| p.extname == ".png" }

macros.each do |path|
  # TODO: change to create_and_upload! after upgrade to Rails 6.0.2
  ActiveStorage::Blob.create_after_upload!(
    io: File.new(path),
    filename: path.basename.to_s,
    content_type: "image/png",
  )
end
