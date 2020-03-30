module Cases
  module Forms
    class SupplierAccount < ApplicationForm
      # -- fields --
      field(:supplier_id, :integer)
      field(:account_number, :string)
      field(:arrears, :string, numericality: true, allow_blank: true)
      field(:has_active_service, :boolean)

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
          arrears: a&.arrears_dollars&.to_s,
          has_active_service: a&.has_active_service,
        })
      end

      # -- santization --
      def arrears=(value)
        super(value&.gsub(/[^\d\.]+/, "")) # strip non-decimal characters
      end

      # -- queries --
      def supplier_options
        suppliers = @partner_repo
          .find_all_suppliers_by_program(@model.program)
          .map { |s| [s.name, s.id] }

        return suppliers
      end

      def map_to_case_supplier_account
        Case::Account.new(
          number: account_number,
          arrears_cents: (arrears.to_f * 100.0).to_i,
          has_active_service: has_active_service.nil? ? true : has_active_service
        )
      end

      private def is_account_required
        if @model.nil?
          return false
        end

        case @model.program
        when Program::Name::Wrap
          validation_context&.include?(:complete) == true
        when Program::Name::Meap
          false
        end
      end
    end
  end
end
