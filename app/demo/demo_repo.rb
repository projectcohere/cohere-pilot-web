class DemoRepo
  # -- lifetime --
  def initialize
    build_db
  end

  # -- commands --
  def sign_in(user)
    @user = user
  end

  # -- queries --
  # method name must match UserRepo for substitutability
  def find_current #_user,
    return @user
  end

  def find_source_user
    return User::Repo.map_record(@users[0])
  end

  def find_source_cases
    page = Pagy.new(count: 1)
    kase = @cases[0]
    return page, [Cases::Views::Repo.map_cell(kase, Cases::Scope::All)]
  end

  def find_applicant_chat(step:)
    chat = @chats[0]
    chat_messages = @chat_messages[0..step].flatten.map do |m|
      Chat::Message::Repo.map_record(m, attachments: m.attachments)
    end

    return Chat::Repo.map_record(chat, chat_messages)
  end

  # -- data --
  private def build_db
    @programs = [
      Program::Record.new(
        id: 1,
        name: "MEAP",
      ),
    ]

    @partners = [
      Partner::Record.new(
        id: 1,
        name: "Test Metro",
        membership: Partner::Membership::Enroller.to_i,
        programs: [@programs[0]],
      ),
      Partner::Record.new(
        id: 2,
        name: "Test Energy",
        membership: Partner::Membership::Supplier.to_i,
        programs: [@programs[0]],
      ),
    ]

    @recipients = [
      Recipient::Record.new(
        id: 1,
        phone_number: Faker::PhoneNumber.phone_number,
        first_name: "Janice",
        last_name: "Sample",
        street: "123 Test St.",
        city: "Testburg",
        state: "Testissippi",
        zip: "12345",
        household_size: 2,
        household_ownership: Recipient::Ownership::Own.to_i,
        household_proof_of_income: Recipient::ProofOfIncome::Weatherization.to_i,
      ),
    ]

    @cases = [
      Case::Record.new(
        id: 1,
        status: Case::Status::Opened.to_i,
        program: @programs[0],
        recipient: @recipients[0],
        enroller: @partners[0],
        supplier: @partners[1],
        created_at: 1.day.ago,
        updated_at: 1.hour.ago,
      ),
    ]

    @chats = [
      Chat::Record.new(
        id: 1,
        recipient: @recipients[0],
      ),
    ]

    macros = Chat::Macro::Repo.get.find_grouped

    def create_message_from_recipient(body = nil, attachments: [])
      return Chat::Message::Record.new(
        sender: "recipient",
        body: body&.to_s,
        attachments: attachments,
        status: Chat::Message::Status::Received.to_i,
      )
    end

    def create_message_from_macro(macro)
      return Chat::Message::Record.new(
        sender: "Gaby",
        body: macro.body,
        attachments: [Chat::Attachment::Record.new(file: macro.file)],
        status: Chat::Message::Status::Received.to_i,
      )
    end

    def create_attachment(filename)
      content_type = case filename.split(".").last
      when "jpg"
        "image/jpg"
      else
        "application/octet-stream"
      end

      return Chat::Attachment::Record.new(
        file: ActiveStorage::Blob.new(
          filename: filename,
          content_type: content_type,
        )
      )
    end

    @chat_messages = [[
      create_message_from_macro(macros[0].list[0]),
    ], [
      create_message_from_recipient(Recipient::Repo.map_name(@recipients[0])),
    ], [
      create_message_from_macro(macros[1].list[0]),
      create_message_from_recipient(@recipients[0].household_size),
      create_message_from_macro(macros[1].list[1]),
      create_message_from_recipient(attachments: [create_attachment("id.jpg")]),
    ]]

    @users = [
      User::Record.new(
        id: 1,
        email: "test@source.com",
        role: Role::Source.to_i,
        partner: @partners[0],
      ),
    ]
  end
end
