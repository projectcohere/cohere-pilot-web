class Case
  module Forms
    # A form object for all the case info
    class Full < ::Form
      use_entity_name!

      # -- props --
      prop(:case)

      # -- fields --
      field(:status, :string)
      fields_from(:inbound, Inbound)
      fields_from(:opened, Opened)

      # -- lifetime --
      def initialize(kase, attrs = {})
        @model = kase

        # construct subforms
        @inbound = Inbound.new(kase, attrs.slice(Inbound.attribute_names))
        @opened = Opened.new(kase, attrs.slice(Opened.attribute_names))

        # set initial values from case
        c = kase
        assign_defaults!(attrs, {
          status: c.status.to_s
        })

        super(attrs)
      end

      # -- commands --
      def save
        context = nil
        if status == "submitted"
          context = :submitted
        end

        if not valid?(context)
          return false
        end

        if @model.record.nil? || @model.recipient.record.nil?
          raise "case must be constructed from a db record!"
        end

        # TODO: need pattern for performing mutations through domain objects
        # and then serializing and saving to db.
        @model.record.transaction do
          # update account
          account = @model.recipient.record.account
          if account.nil?
            account = Recipient::Account::Record.new
          end

          account.assign_attributes(
            number: account_number,
            arrears: arrears
          )

          # update household
          household = @model.recipient.record.household
          if household.nil?
            household = Recipient::Household::Record.new
          end

          household.assign_attributes(
            size: household_size,
            income_history: income_history.map(&:attributes)
          )

          # save recipient
          @model.recipient.record.update!(
            first_name: first_name,
            last_name: last_name,
            phone_number: phone_number,
            street: street,
            street2: street2,
            city: city,
            state: state,
            zip: zip,
            account: account,
            dhs_number: dhs_number,
            household: household
          )

          # save case
          @model.record.update!(
            status: status
          )
        end

        true
      end

      # -- queries --
      def name
        @model.recipient.name
      end

      def enroller_name
        @model.supplier.name
      end

      def supplier_name
        @model.supplier.name
      end

      def statuses
        [
          :opened,
          :pending,
          :submitted,
          :approved,
          :rejected
        ]
      end

      def documents
        @model.recipient.documents
      end
    end
  end
end
