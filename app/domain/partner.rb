class Partner < ::Entity
  # -- props --
  prop(:id)
  prop(:name)
  prop(:membership_class)

  # -- commands --
  def open_case(enroller, account:, profile:)
    if membership_class != MembershipClass::Supplier
      raise "only suppliers can open cases"
    end

    Case.open(
      program: Program::Name::Meap,
      profile: profile,
      enroller: enroller,
      supplier: self,
      supplier_account: account
    )
  end
end
