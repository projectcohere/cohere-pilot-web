module Support
  module Factories
    def self.stub_all
      # TODO: search for all types to stub in domain
      types_to_stub = [
        Role,
        User,
        User::Invitation,
        Partner,
        Program,
        Program::Contract,
        Case,
        Case::Account,
        Case::Recipient,
        Case::Assignment,
        Recipient::Profile,
        Recipient::Household,
        Document,
        Chat,
        Chat::Message,
        Chat::Attachment,
        Chat::Recipient,
        Sms::Message,
        Sms::Media,
        Stats,
        Stats::Case,
        Stats::Supplier,
        Stats::Durations,
        Stats::Duration,
        Stats::Quantity,
        Name,
        Address,
        Phone,
      ]

      types_to_stub.each do |type_to_stub|
        define_stub(type_to_stub)
      end
    end

    # accepts a type to stub. the type must include `Initializable`.
    # synthesizes a `.stub` factory method that makes every prop optional.
    def self.define_stub(type_to_stub)
      props_required = type_to_stub.props
        .filter { |_, v| v.equal?(Initializable::Required) }
        .transform_values { |_| nil }
        .freeze

      type_to_stub.define_singleton_method(:stub) do |**kwargs|
        kwargs.with_defaults!(props_required)

        if props_required.empty? && kwargs.empty?
          type_to_stub.new
        else
          type_to_stub.new(**kwargs)
        end
      end
    end
  end
end

Support::Factories.stub_all
