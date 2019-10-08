Rails.application.routes.draw do
  constraints(Clearance::Constraints::SignedOut.new) do
    root(to: "sessions#new", as: :sign_in)

    resource(:session,
      only: [:create]
    )
  end

  constraints(Clearance::Constraints::SignedIn.new) do
    root(to: "home#show")

    resource(:session,
      only: [:destroy]
    )
  end
end
