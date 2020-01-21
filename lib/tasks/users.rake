namespace :users do
  desc "Invites users from a csv"
  task invite: :environment do
    csv = $stdin.read
    if csv.blank?
      raise "must provide a csv through STDIN"
    end

    send_invitations = Users::SendInvitations.new
    send_invitations.(csv)
  end
end
