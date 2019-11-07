Rails.application.routes.draw do
  # development
  if Rails.env.development?
    require "sidekiq/web"
    mount(Sidekiq::Web => "/sidekiq")
  end

  # -- signed-out --
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
    namespace(:messages) do
      post(:front, constraints: { format: :json })
    end

    # fallback
    get("*path", to: redirect(sign_in_path))
  end

  # -- signed-in --
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
      resources(:supplier, only: %i[
        index
        new
        create
      ])

      resources(:dhs, only: %i[
        index
        edit
        update
      ])

      resources(:enroller, only: %i[
        index
        show
      ])
    end

    # fallback
    get("*path", to: redirect(cases_path), constraints: ->(req) {
      req.path.exclude? "rails/active_storage"
    })
  end
end
