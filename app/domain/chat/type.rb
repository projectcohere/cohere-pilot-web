class Chat
  module Type
    # -- options --
    Text = :text

    # -- queries --
    def self.all
      @all ||= [
        Text
      ]
    end
  end
end
