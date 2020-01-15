class PhoneNumber
  extend ActiveModel::Naming

  # -- lifetime --
  def initialize(original = nil)
    @original = original || ""
  end

  # -- commands --
  def validate
    if @original.blank?
      errors.add(:value, "must not be blank")
    end

    if value.length != 10
      errors.add(:value, "must be a 10-digit phone number.")
    end

    return errors.blank?
  end

  alias :valid? :validate

  # -- queries --
  def value
    @value ||= begin
      val = @original.gsub(/\D+/, "")
      val.length == 11 ? val.delete_prefix("1") : val
    end
  end

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end

  def blank?
    @original.blank?
  end

  def to_s
    return value
  end
end
