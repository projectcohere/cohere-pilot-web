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

    # front-webhooks
    namespace(:front) do
      post(:messages, constraints: { format: :json })
    end

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
      edit
      update
    ])

    # cases/role-scoped
    namespace(:cases) do
      resources(:inbound, only: %i[
        index
        new
        create
      ])

      resources(:opened, only: %i[
        index
        edit
        update
      ])

      resources(:submitted, only: %i[
        index
        show
      ])
    end

    # fallback
    get("*path", to: redirect(cases_path))
  end

  # development
  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end
end
