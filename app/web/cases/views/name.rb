module Cases
  module Views
    class Name < ::Value
      # -- props --
      prop(:first)
      prop(:last)

      # -- queries --
      def to_s
        return "#{first} #{last}"
      end
    end
  end
end
