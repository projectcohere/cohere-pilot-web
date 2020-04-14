module Routes
  module Auth
    def signed_out(&routes)
      constraint = Clearance::Constraints::SignedOut.new
      scope(constraints: constraint) { routes.(constraint) }
    end

    def signed_in(role: nil, &routes)
      if role == nil
        constraint = Clearance::Constraints::SignedIn.new
        scope(constraints: constraint) { routes.(constraint) }
      else
        membership = Partner::Membership.from_key(role)
        constraint = Clearance::Constraints::SignedIn.new do |user_rec|
          # TODO: sign the user in here
          User::Repo.map_role(user_rec).membership == membership
        end

        scope(constraints: constraint, module: role) { routes.(constraint) }
      end
    end
  end
end
