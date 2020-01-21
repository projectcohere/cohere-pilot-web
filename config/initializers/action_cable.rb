config = ActionCable.server.config
config.connection_class = -> { Chats::Connection }
