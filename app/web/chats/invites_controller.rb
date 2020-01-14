module Chats
  class InvitesController < ApplicationController
    def new
      @phone_number = PhoneNumber.new
    end

    def create
      @phone_number = PhoneNumber.new(
        params
          .require(:invite)
          .require(:phone_number)
      )

      if not @phone_number.valid?
        flash.now[:alert] = "Please enter a 10-digit phone number."
        return render(:new)
      end

      did_send = SendInvite.(@phone_number)
      if not did_send
        flash.now[:alert] = "There was a problem sending the invite. Please try again."
        return render(:new)
      end

      cookies.encrypted.signed[:chat_invite_phone_number] = @phone_number
      return redirect_to(verify_chat_invites_path)
    end

    def edit
    end

    def update
    end
  end
end
