class Recipient < ::Entity
  # TODO: should this be generalized for the aggregate root?
  prop(:record, default: nil)

  # -- props --
  prop(:id, default: nil)
  prop(:profile)
  prop(:dhs_account, default: nil)
  prop(:documents, default: [])
  props_end!

  # -- creation --
  def self.register(profile)
    Recipient.new(
      profile: profile,
      # figure out how to get rid of these
      id: nil,
    )
  end

  # -- commands --
  def update_profile(profile)
    @profile = profile
  end

  def attach_dhs_account(dhs_account)
    @dhs_account = dhs_account
  end

  def add_documents_from_message(message)
    message.attachments.each do |attachment|
      @documents << Document.new(source_url: attachment.url)
    end
  end

  # -- queries --
  def new_documents
    @documents.filter { |d| d.id.nil? }
  end

  # -- events --
  def did_save(record)
    @record = record
    @id = record.id
  end
end
