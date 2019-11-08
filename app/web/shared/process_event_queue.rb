class ProcessEventQueue
  # -- lifetime --
  def self.get
    ProcessEventQueue.new
  end

  def initialize(event_queue: EventQueue.get)
    @event_queue = event_queue
  end

  # -- command --
  def call
    @event_queue.drain do |event|
      case event
      when Case::Events::DidOpen
        CasesMailer.did_open(event.case_id.val).deliver_later
      when Case::Events::DidSubmit
        CasesMailer.did_submit(event.case_id.val).deliver_later
      when User::Events::DidInvite
        UsersMailer.did_invite(event.user_id.val).deliver_later
      end
    end
  end
end
