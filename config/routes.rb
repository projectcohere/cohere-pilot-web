Rails.application.routes.draw do
  constraints(Clearance::Constraints::SignedOut.new) do
    sign_in_path = "/sign-in"

    # root
    root(to: redirect(sign_in_path), as: :root_signed_out)

    # auth
    get(sign_in_path, to: "sessions#new")

    resource(:session, only: %i[
      create
    ])

    # fallback
    get("*path", to: redirect(sign_in_path))
  end

  constraints(Clearance::Constraints::SignedIn.new) do
    cases_path = "/cases"

    # root
    root(to: redirect(cases_path))

    # auth
    delete("/sign-out", to: "sessions#destroy")

    # cases
    resources(:cases, only: %i[
      index
      new
      create
      edit
      update
    ]) do
      get(:inbound, on: :collection)
    end

    # fallback
    get("*path", to: redirect(cases_path))
  end
end
