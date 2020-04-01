def require_many(path, scope: nil)
  if scope != nil
    path = "#{scope}/#{path}"
  end

  Dir[path].each do |file_path|
    if scope != nil
      file_path.delete_prefix!("#{scope}/")
    end

    require file_path
  end
end
