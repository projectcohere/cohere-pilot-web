module Cases
  module Forms
    class SupplierAccount < ApplicationForm
      # -- fields --
      field(:supplier_id, :integer, presence: { if: :required? })
      field(:account_number, :string, presence: { if: :required? })
      field(:arrears, :string, presence: { if: :required? }, numericality: { allow_blank: true })
      field(:active_service, :boolean)

      # -- fields/validation
      validate(:supplies_program!)

      # -- lifecycle --
      def initialize(model, attrs = {}, partner_repo: Partner::Repo.get)
        @partner_repo = partner_repo
        super(model, attrs)
      end

      protected def initialize_attrs(attrs)
        if not @model.respond_to?(:supplier_account)
          assign_defaults!(attrs, supplier_id: suppliers.first&.id)
          return
        end

        a = @model.supplier_account
        assign_defaults!(attrs, {
          supplier_id: a&.supplier_id,
          account_number: a&.number,
          arrears: a&.arrears&.dollars&.to_s,
          active_service: a&.active_service?,
        })
      end

      # -- santization --
      def arrears=(value)
        super(value&.gsub(/[^\d\.]+/, "")) # strip non-decimal characters
      end

      # -- queries --
      private def required?
        return validation_context&.include?(:new_referral) != true
      end

      # -- queries/suppliers
      def supplier_options
        return suppliers.map { |s| [s.name, s.id] }
      end

      private def suppliers
        @suppliers ||= @partner_repo
          .find_all_suppliers_by_program(@model&.program&.id || @parent.program_id)

        return @suppliers
      end

      def supplies_program!
        if suppliers.none? { |s| s.id == supplier_id }
          errors.add(:supplier_id, "must be part of program")
        end
      end

      # -- queries/transformation
      def map_to_supplier_account
        return Case::Account.new(
          supplier_id: supplier_id,
          number: account_number,
          arrears: Money.dollars(arrears),
          active_service: active_service.nil? ? true : active_service
        )
      end
    end
  end
end
