Rails.application.routes.draw do
  constraints(Clearance::Constraints::SignedOut.new) do
    root(to: "sessions#new", as: :sign_in)

    resource(:session,
      only: %i[create]
    )

    resources(:passwords,
      only: %i[create new]
    )
  end

  constraints(Clearance::Constraints::SignedIn.new) do
    root(to: "home#show")
  end
end
