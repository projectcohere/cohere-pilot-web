class RemoveInvitationFromChats < ActiveRecord::Migration[6.0]
  def change
    remove_column(:chats, :invitation_token, :string)
    remove_column(:chats, :invitation_token_expires_at, :datetime)
  end
end
