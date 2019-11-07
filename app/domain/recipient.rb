class Recipient < ::Entity
  prop(:record, default: nil)

  # -- props --
  prop(:id, default: nil)
  prop(:profile)
  prop(:dhs_account, default: nil)
  props_end!

  # -- commands --
  def update_profile(profile)
    @profile = profile
  end

  def attach_dhs_account(dhs_account)
    @dhs_account = dhs_account
  end

  # -- events --
  def did_save(record)
    @record = record
    @id = record.id
  end
end
