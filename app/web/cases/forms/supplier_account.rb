module Cases
  module Forms
    class SupplierAccount < ApplicationForm
      # -- fields --
      field(:supplier_id, :integer)
      field(:account_number, :string)
      field(:arrears, :string, numericality: true, allow_blank: true)
      field(:active_service, :boolean)

      # -- fields/validation
      validates(:account_number, presence: true, if: :is_account_required)
      validates(:arrears, presence: true, if: :is_account_required)

      # -- lifecycle --
      def initialize(model, attrs = {}, partner_repo: Partner::Repo.get)
        @partner_repo = partner_repo
        super(model, attrs)
      end

      protected def initialize_attrs(attrs)
        if @model.nil?
          return
        end

        assign_defaults!(attrs, {
          supplier_id: @model.supplier_id,
        })

        a = @model.supplier_account
        assign_defaults!(attrs, {
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
      def supplier_options
        suppliers = @partner_repo
          .find_all_suppliers_by_program(@model.program.id)
          .map { |s| [s.name, s.id] }

        return suppliers
      end

      private def is_account_required
        return validation_context&.include?(:new_referral) != true
      end

      # -- queries/transformation
      def map_to_supplier_account
        return Case::Account.new(
          number: account_number,
          arrears: Money.dollars(arrears),
          active_service: active_service.nil? ? true : active_service
        )
      end

    end
  end
end
