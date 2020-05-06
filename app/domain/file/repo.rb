class File
  class Repo < ::Repo
    include Service

    # -- queries --
    # -- queries/many
    def find_all_by_ids(ids)
      files = ActiveStorage::Blob
        .where(id: ids)

      return files
    end

    def find_all_by_filenames(filenames)
      files = ActiveStorage::Blob
        .where(filename: filenames)

      return files
    end

    # -- commands --
    def save_uploaded_files(files)
      transaction do
        files.map do |file|
          blob = ActiveStorage::Blob.create_and_upload!(
            io: file.tempfile,
            filename: file.original_filename,
            content_type: file.content_type,
          )

          blob.id
        end
      end
    end

    # -- commands/helpers
    private def transaction(&block)
      ActiveStorage::Blob.transaction(&block)
    end
  end
end
