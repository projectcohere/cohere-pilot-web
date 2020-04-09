module Routes
  module Authentication
    def signed_out(&routes)
      constraints(Clearance::Constraints::SignedOut.new, &routes)
    end

    def signed_in(role: nil, &routes)
      constraint = if role == nil
        Clearance::Constraints::SignedIn.new
      else
        Clearance::Constraints::SignedIn.new do |user_rec|
          User::Repo.map_role(user_rec).name == role
        end
      end

      constraints(constraint) do
        if role != nil
          scope(module: role, &routes)
        else
          routes.()
        end
      end
    end
  end
end
