class Chat
  class Macro
    class Repo < ::Repo
      # -- lifetime --
      def self.get
        Repo.new
      end

      def initialize(file_repo: File::Repo.get)
        @file_repo = file_repo
      end

      # -- queries --
      # -- queries/many
      def find_all
        # load raw data
        data_list = YAML.load_file("macros/all.yaml")
        data_filenames = data_list.pluck("filename").compact.uniq

        # index files by filename
        files = {}
        @file_repo.find_all_by_filenames(data_filenames).each do |file|
          files[file.filename.to_s] = file
        end

        # build entities
        macros = data_list.map do |data|
          Macro.new(
            name: data["name"],
            body: data["body"],
            attachment: files[data["filename"]],
          )
        end

        return macros
      end
    end
  end
end