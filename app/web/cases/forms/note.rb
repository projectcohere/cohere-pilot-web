module Cases
  module Forms
    class Note < ApplicationForm
      # -- fields --
      field(:body, :string, presence: true)

      # -- ApplicationForm --
      def self.entity_type
        return Case::Note
      end
    end
  end
end
