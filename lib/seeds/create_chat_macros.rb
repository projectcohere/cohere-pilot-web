Rails.root.join("macros").children.each do |macro_path|
  # TODO: change to create_and_upload! after upgrade to Rails 6.0.2
  ActiveStorage::Blob.create_after_upload!(
    io: File.new(macro_path),
    filename: macro_path.basename.to_s,
    content_type: "image/png",
  )
end
