class Chat
  class Macro
    class Repo < ::Repo
      include Service

      # -- lifetime --
      def initialize(file_repo: File::Repo.get)
        @file_repo = file_repo
      end

      # -- queries --
      # -- queries/one
      def find_initial
        return store[0].list[0]
      end

      # -- queries/many
      def find_grouped
        return store
      end

      # -- queries/store --
      private def store
        return Rails.cache.fetch("macro-store") do
          build_store
        end
      end

      private def build_store
        # load raw data
        group_data = YAML.load_file("macros/groups.yaml")
        files_data = group_data
          .flat_map { |g| g["list"].pluck("file") }
          .compact

        # index files by filename
        files = {}
        @file_repo.find_all_by_filenames(files_data).each do |file|
          files[file.filename.to_s] = file
        end

        # map into values
        groups = group_data.map do |data|
          Macro::Group.new(
            name: data["name"],
            list: data["list"].map { |data|
              Macro.new(
                name: data["name"],
                body: data["body"],
                file: files[data["file"]],
              )
            },
          )
        end

        return groups
      end
    end
  end
end
