module Cases
  module Forms
    class UtilityAccount < ApplicationForm
      # -- fields --
      field(:supplier_id, :integer)
      field(:account_number, :string)
      field(:arrears, :string, numericality: true, allow_blank: true)
      field(:has_active_service, :boolean)

      validate(:has_account_unless_referral)

      # -- lifecycle --
      def initialize(model, attrs = {}, supplier_repo: Supplier::Repo.get)
        @supplier_repo = supplier_repo
        super(model, attrs)
      end

      protected def initialize_attrs(attrs)
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

      # -- validation --
      def has_account_unless_referral
        if validation_context == :referral
          return
        end

        if account_number.blank?
          errors.add(:account_number, "can't be blank")
        end

        if arrears.blank?
          errors.add(:arrears, "can't be blank")
        end
      end

      # -- queries --
      def supplier_options
        @supplier_repo.find_all_by_program(@model.program).map do |s|
          [s.name, s.id]
        end
      end
    end
  end
end
