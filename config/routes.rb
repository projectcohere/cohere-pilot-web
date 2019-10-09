Rails.application.routes.draw do
  constraints(Clearance::Constraints::SignedOut.new) do
    root(to: "user/sessions#new", as: :sign_in)

    resource(:session,
      only: [:create],
      controller: "user/sessions"
    )
  end

  constraints(Clearance::Constraints::SignedIn.new) do
    root(to: "home#show")

    resource(:session,
      only: [:destroy],
      controller: "user/sessions"
    )
  end
end
