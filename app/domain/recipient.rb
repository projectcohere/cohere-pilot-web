class Recipient < ::Entity
  prop(:record, default: nil)

  # -- props --
  prop(:id, default: nil)
  prop(:profile)
  prop(:dhs_account, default: nil)
  props_end!

  # -- commands --
  def add_dhs_data(dhs_account)
    @dhs_account = dhs_account
  end

  def add_cohere_data(profile, dhs_account)
    @profile = profile
    @dhs_account = dhs_account
  end

  # -- events --
  def did_save(record)
    @record = record
    @id = record.id
  end
end
