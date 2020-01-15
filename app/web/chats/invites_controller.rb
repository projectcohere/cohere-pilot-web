module Chats
  class InvitesController < ApplicationController
    def new
      @phone_number = PhoneNumber.new
    end

    def create
      @phone_number = PhoneNumber.new(
        params.require(:invite).require(:phone_number)
      )

      if not @phone_number.valid?
        flash.now[:alert] = "Please enter a 10-digit phone number."
        return render(:new)
      end

      invite_sid = SendInvite.(@phone_number.to_s)
      if invite_sid == nil
        flash.now[:alert] = "Please double check your phone number, and try again."
        return render(:new)
      end

      cookies.encrypted.signed[:chat_invite_sid] = invite_sid
      cookies.encrypted.signed[:chat_invite_phone_number] = @phone_number.to_s

      return redirect_to(verify_chat_invites_path)
    end

    def edit
      invite_sid = cookies.encrypted.signed[:chat_invite_sid]
      if invite_sid == nil
        return redirect_to(new_chat_invite_path)
      end

      phone_number = cookies.encrypted.signed[:chat_invite_phone_number]
      if phone_number == nil
        return redirect_to(new_chat_invite_path)
      end
    end

    def update
      invite_sid = cookies.encrypted.signed[:chat_invite_sid]
      if invite_sid == nil
        return redirect_to(new_chat_invite_path)
      end

      phone_number = PhoneNumber.new(cookies.encrypted.signed[:chat_invite_phone_number])
      if not phone_number.valid?
        return redirect_to(new_chat_invite_path)
      end

      did_verify = VerifyInvite.(
        invite_sid,
        params.require(:invite).require(:code)
      )

      if not did_verify
        flash.now[:alert] = "Please double check your code, and try again."
        return render(:edit)
      end

      session_token = StartSession.(phone_number.to_s)
      if session_token == nil
        return redirect_to(new_chat_invite_path)
      end

      cookies.encrypted.signed[:chat_session_token] = session_token
      cookies.delete(:chat_invite_sid)
      cookies.delete(:chat_invite_phone_number)

      redirect_to(chat_path)
    end
  end
end
