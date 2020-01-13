module Support
  module Factories
    def self.stub_all
      types_to_stub = [
        User,
        Case,
        Case::Account,
        Recipient,
        Recipient::Profile,
        Recipient::Name,
        Recipient::Address,
        Recipient::Phone,
        Recipient::DhsAccount,
        Recipient::Household,
        Document,
        Enroller,
        Supplier,
        Chat,
        Chat::Invitation,
        Chat::Message,
        Mms::Message,
        Mms::Message::Sender,
        Mms::Message::Attachment,
      ]

      types_to_stub.each do |type_to_stub|
        define_stub(type_to_stub)
      end
    end

    # accepts a type to stub. the type must include `Initializable`.
    # synthesizes a `.stub` factory method that makes every prop optional.
    def self.define_stub(type_to_stub)
      props_required = type_to_stub.prop_definitions
        .filter { |_, v| v.equal?(Initializable::Required) }
        .transform_values { |_| nil }
        .freeze

      type_to_stub.define_singleton_method(:stub) do |**kwargs|
        kwargs.with_defaults!(props_required)
        type_to_stub.new(**kwargs)
      end
    end
  end
end

Support::Factories.stub_all
