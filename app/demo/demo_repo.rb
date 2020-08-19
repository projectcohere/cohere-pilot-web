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
  # -- queries/users
  # method name must match UserRepo for substitutability
  def find_current #_user,
    return @user
  end

  def find_source_user
    return User::Repo.map_record(@users[0])
  end

  def find_state_user
    return User::Repo.map_record(@users[1])
  end

  def find_nonprofit_user
    return User::Repo.map_record(@users[2])
  end

  # -- queries/partners
  def find_all_suppliers_by_program(_)
    return [@partners[1]]
  end

  # -- queries/programs
  def find_all_by_partner(_)
    return @programs
  end

  # -- queries/cases
  def find_cases(scope)
    page = Pagy.new(count: 1)
    kase = Cases::Views::Repo.map_cell(find_case, scope)
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
    form = make_form(view, filled ? make_attributes(find_case) : {})
    return form
  end

  def find_active_case(step:)
    view = Cases::Views::Repo.map_detail_from_record(find_case(step: step))
    form = make_form(view)
    return form
  end

  def find_referral_case
    p = @programs.map { |r| Program::Repo.map_record(r) }
    view = Cases::Views::Repo.map_reference(find_case(step: 5))
    form = Cases::Views::ProgramForm.new(view, p, { "program_id" => p[1].id })
    return form
  end

  # -- queries/chats
  def find_by_recipient_with_messages(_)
    return find_chat(step: @chat_step || 1)
  end

  def find_chat(step:)
    chat = @chats[0]
    chat_messages = @chat_messages[0..step].flatten.map do |m|
      Chat::Message::Repo.map_record(m, attachments: m.attachments)
    end

    return Chat::Repo.map_record(chat, chat_messages)
  end

  # -- queries/reports
  def find_report_form
    return Reports::Views::Form.new(nil, program_repo: self)
  end

  # -- helpers --
  private def find_case(step: 0)
    c = @cases[0]
    r = c.recipient

    if step >= 1
      r.assign_attributes(
        dhs_number: "192283A405",
        household_size: 2,
        household_income_cents: 625_00,
      )
    end

    if step >= 2
      @chat_step = 2
    end

    if step >= 3
      @chat_step = 3
    end

    if step >= 4
      @chat_step = 4

      c.status = :submitted
      c.documents = @documents
    end

    if step >= 5
      @chat_step = 5

      c.status = :approved
    end

    return c
  end

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
        arrears: Money.cents(r.supplier_account_arrears_cents).dollars,
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
      Partner::Record.new(
        id: 3,
        name: "Michigan",
        membership: Partner::Membership::Governor.to_i,
        programs: [],
      ),
    ]

    @recipients = [
      Recipient::Record.new(
        id: 1,
        phone_number: "5553334444",
        first_name: "Janice",
        last_name: "Sample",
        street: "123 Test St.",
        city: "Testburg",
        state: "Testissippi",
        zip: "12345",
        household_proof_of_income: Recipient::ProofOfIncome::Dhs.to_i,
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

    @blobs = [
      build_blob("id.jpg"),
      build_blob("document.jpg"),
      build_blob("contract.jpg"),
    ]

    @documents = [
      Document::Record.new(file: @blobs[0]),
      Document::Record.new(file: @blobs[1]),
      Document::Record.new(file: @blobs[2], classification: :contract),
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
        build_msg(body: find_case(step: 1).recipient.household_size),
      ],
      [
        build_msg_from_macro(1, 1),
        build_msg(attachments: [Chat::Attachment::Record.new(file: @blobs[0])]),
      ],
      [
        build_msg_from_macro(3, 0),
        build_msg(attachments: [Chat::Attachment::Record.new(file: @blobs[1])]),
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
        email: "source@testmetro.com",
        role: Role::Source.to_i,
        partner: @partners[0],
      ),
      User::Record.new(
        id: 2,
        email: "test@michigan.gov",
        role: Role::Governor.to_i,
        partner: @partners[2],
      ),
      User::Record.new(
        id: 3,
        email: "agent@testmetro.org",
        role: Role::Agent.to_i,
        partner: @partners[0],
        admin: true,
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

  def build_blob(filename)
    content_type = case filename.split(".").last
    when "jpg"
      "image/jpg"
    else
      "application/octet-stream"
    end

    return ActiveStorage::Blob.new(
      filename: filename,
      content_type: content_type,
    )
  end
end
