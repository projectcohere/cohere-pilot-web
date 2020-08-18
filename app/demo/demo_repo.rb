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

  def find_all_suppliers_by_program(_)
    return [@partners[1]]
  end

  def find_source_user
    return User::Repo.map_record(@users[0])
  end

  def find_source_cases
    page = Pagy.new(count: 1)
    kase = Cases::Views::Repo.map_cell(@cases[0], Cases::Scope::All)
    return page, [kase]
  end

  def find_pending_case
    p = @programs.map { |r| Program::Repo.map_record(r) }
    view = Cases::Views::Repo.map_pending(SecureRandom.base58, p[0])
    form = Cases::Views::ProgramForm.new(view, p, { "program_id" => p[0].id })
    return form
  end

  def find_new_case(filled: false)
    p = Program::Repo.map_record(@programs[0])
    view = Cases::Views::Repo.map_pending(SecureRandom.base58, p)
    form = make_form(view, filled ? make_attributes(@cases[0]) : {})
    return form
  end

  def find_applicant_chat(step:)
    chat = @chats[0]
    chat_messages = @chat_messages[0..step].flatten.map do |m|
      Chat::Message::Repo.map_record(m, attachments: m.attachments)
    end

    return Chat::Repo.map_record(chat, chat_messages)
  end

  # -- helpers --
  private def make_form(model, attrs = {})
    return Case::Policy.new(@user).with_case(model) do |p|
      Cases::Views::Form.new(model, "", attrs) do |subform|
        p.permit?(:"edit_#{subform}")
      end
    end
  end

  private def make_attributes(r)
    return {
      contact: r.recipient.then { |r| {
        first_name: r.first_name,
        last_name: r.last_name,
        phone_number: r.phone_number,
      } },
      address: r.recipient.then { |r| {
        street: r.street,
        street2: r.street2,
        city: r.city,
        zip: r.zip,
        geography: true,
      } },
      household: r.recipient.then { |r| {
        proof_of_income: r.household_proof_of_income,
      } },
      supplier_account: {
        supplier_id: @partners[1].id,
        account_number: r.supplier_account_number,
        arrears: Money.cents(r.supplier_account_arrears_cents).to_s,
      },
    }
  end

  # -- data --
  private def build_db
    @programs = [
      Program::Record.new(
        id: 1,
        name: "MEAP",
        requirements: {
          supplier_account: %i[
            present
          ]
        }
      ),
      Program::Record.new(
        id: 2,
        name: "WRAP",
        requirements: {
          supplier_account: %i[
            present
            active_service
          ]
        }
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
        supplier_account_number: "1A49402932",
        supplier_account_arrears_cents: 233_10,
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

    @chat_messages = [
      [
        build_msg_from_macro(0, 0),
      ],
      [
        build_msg(body: Recipient::Repo.map_name(@recipients[0])),
      ],
      [
        build_msg_from_macro(1, 0),
        build_msg(body: @recipients[0].household_size),
      ],
      [
        build_msg_from_macro(1, 1),
        build_msg(attachments: [build_attachment("id.jpg")]),
      ],
      [
        build_msg_from_macro(3, 0),
        build_msg(attachments: [build_attachment("document.jpg")]),
      ],
      [
        build_msg_from_macro(5, 5),
        build_msg(body: "Thank you!."),
        build_msg_from_macro(6, 1),
        build_msg(body: "Yes"),
      ],
    ]

    @users = [
      User::Record.new(
        id: 1,
        email: "test@source.com",
        role: Role::Source.to_i,
        partner: @partners[0],
      ),
    ]
  end

  def build_msg(body: nil, attachments: [])
    return Chat::Message::Record.new(
      sender: "recipient",
      body: body&.to_s,
      attachments: attachments,
      status: Chat::Message::Status::Received.to_i,
    )
  end

  def build_msg_from_macro(group, item)
    @macros ||= begin
      Chat::Macro::Repo.get.find_grouped
    end

    macro = @macros[group].list[item]
    return Chat::Message::Record.new(
      sender: "Gaby",
      body: macro.body,
      attachments: [Chat::Attachment::Record.new(file: macro.file)],
      status: Chat::Message::Status::Received.to_i,
    )
  end

  def build_attachment(filename)
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
end
