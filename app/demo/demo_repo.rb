require "faker"

class DemoRepo
  include ActionView::Helpers::TranslationHelper

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
    return [@partners[1], @partners[3]]
  end

  # -- queries/programs
  def find_all_by_partner(_)
    return @programs
  end

  # -- queries/cases
  def find_cases(scope)
    cases = if scope.all?
      @cases
    elsif @user != nil && @user.role.agent?
      @cases.slice(0, 2)
    else
      @cases.slice(0, 1)
    end

    cells = cases.map { |r| Cases::Views::Repo.map_cell(r, scope) }
    return Pagy.new(count: cells.count), cells
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

  def find_active_case(step:, has_id: false)
    view = Cases::Views::Repo.map_detail_from_record(find_case(step: step, has_id: has_id))
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
    @chat_step = step

    chat = @chats[0]
    chat_messages = @chat_messages[0..step].flatten.map do |m|
      Chat::Message::Repo.map_record(m, attachments: m.attachments)
    end

    return Chat::Repo.map_record(chat, chat_messages)
  end

  def find_current_chat
    if @chat_step != nil
      return find_chat(step: @chat_step)
    end
  end

  # -- queries/reports
  def find_report_form
    return Reports::Views::Form.new(nil, program_repo: self)
  end

  # -- helpers --
  private def find_case(step: 0, has_id: false)
    c = @cases[0]
    r = c.recipient

    if has_id
      c.documents = [@documents[0]]
    end

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
        name: "DTE Energy",
        membership: Partner::Membership::Supplier.to_i,
        programs: [@programs[0]],
      ),
      Partner::Record.new(
        id: 3,
        name: "Michigan",
        membership: Partner::Membership::Governor.to_i,
        programs: [],
      ),
      Partner::Record.new(
        id: 4,
        name: "Consumers Energy",
        membership: Partner::Membership::Supplier.to_i,
        programs: [@programs[0]],
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
        state: "Michigan",
        zip: "12345",
        household_proof_of_income: Recipient::ProofOfIncome::Dhs.to_i,
      ),
    ]

    5.times do |i|
      first_name, last_name = if i == 0
        ["Dee", "Hock"]
      else
        [Faker::Name.first_name, Faker::Name.last_name]
      end

      @recipients.push(Recipient::Record.new(
        id: @recipients.count + 1,
        phone_number: "555#{Faker::Number.number(digits: 7)}",
        first_name: first_name,
        last_name: last_name,
        street: "#{Faker::Number.number(digits: 3)} Test St.",
        city: "Testburg",
        state: "Michigan",
        zip: "12345",
        household_proof_of_income: Recipient::ProofOfIncome::Dhs.to_i,
      ))
    end

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

    5.times do
      @cases.push(Case::Record.new(
        id: @cases.count + 1,
        status: Case::Status::Approved.to_i,
        program: @programs[0],
        recipient: @recipients[@cases.count],
        enroller: @partners[0],
        supplier: @partners[1],
        supplier_account_number: Faker::Alphanumeric.alphanumeric(number: 10).upcase,
        supplier_account_arrears_cents: Faker::Number.number(digits: 5),
        created_at: 2.days.ago,
        updated_at: 2.days.ago,
      ))
    end

    @blobs = [
      build_blob("id.jpg"),
      build_blob("contract.jpg"),
      build_blob("approved.png"),
      build_blob("referral.png"),
    ]

    @documents = [
      Document::Record.new(file: @blobs[0]),
      Document::Record.new(file: @blobs[1], classification: :contract),
    ]

    @chats = [
      Chat::Record.new(
        id: 1,
        recipient: @recipients[0],
      ),
    ]

    @chat_messages = [
      [
        build_msg_from_macro(0, 0, at: 1.minute),
      ],
      [
        build_msg(body: Recipient::Repo.map_name(@recipients[0]), at: 2.minutes),
      ],
      [
        build_msg_from_macro(1, 0, at: 3.minutes),
        build_msg(body: find_case(step: 1).recipient.household_size, at: 3.minutes + 13.seconds),
      ],
      [
        build_msg_from_macro(1, 1, at: 4.minutes + 5.seconds),
      ],
      [
        build_msg(files: [@blobs[0]], at: 5.minutes + 7.seconds),
      ],
      [
        build_msg(sender: "Gaby", files: [@blobs[2]], at: 6.minutes + 3.seconds),
        build_msg(body: "Thank you so much!", at: 6.minutes + 12.seconds),
        build_msg(sender: "Gaby", files: [@blobs[3]], at: 6.minutes + 49.seconds),
        build_msg(body: "Yes", at: 7.minutes),
      ],
    ]

    @users = [
      User::Record.new(
        id: 1,
        email: "call-center-rep@utility.com",
        role: Role::Source.to_i,
        partner: @partners[0],
      ),
      User::Record.new(
        id: 2,
        email: "caseworker@state.gov",
        role: Role::Governor.to_i,
        partner: @partners[2],
      ),
      User::Record.new(
        id: 3,
        email: "caseworker@nonprofit.org",
        role: Role::Agent.to_i,
        partner: @partners[0],
        admin: true,
      ),
    ]
  end

  def build_msg(sender: "recipient", body: nil, files: [], at:)
    return Chat::Message::Record.new(
      sender: sender,
      body: body&.to_s,
      attachments: files.map { |f| Chat::Attachment::Record.new(file: f) },
      status: Chat::Message::Status::Received.to_i,
      created_at: chat_time + at,
    )
  end

  def build_msg_from_macro(group, item, at:)
    @macros ||= begin
      Chat::Macro::Repo.get.find_grouped
    end

    macro = @macros[group].list[item]
    return Chat::Message::Record.new(
      sender: "Gaby",
      body: macro.body,
      attachments: [Chat::Attachment::Record.new(file: macro.file)],
      status: Chat::Message::Status::Received.to_i,
      created_at: chat_time + at,
    )
  end

  def build_blob(filename)
    content_type = case filename.split(".").last
    when "jpg"
      "image/jpg"
    when "png"
      "image/png"
    else
      "application/octet-stream"
    end

    return ActiveStorage::Blob.new(
      filename: filename,
      content_type: content_type,
    )
  end

  private def chat_time
    return DateTime.civil(2020, 1, 25, 5, 25, 00, Rational(-6, 24))
  end
end
