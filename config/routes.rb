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
    root(to: redirect(sign_in_path), as: :root_sign_in)

    # users
    scope(module: "users") do
      get(sign_in_path, to: "sessions#new")

      resources(:sessions, only: %i[
        create
      ])

      resources(:passwords, only: %i[
        create
      ]) do
        get("forgot", on: :collection, action: :new)
      end

      resources(:user, only: []) do
        resource(:password, controller: "passwords", only: %i[
          edit
          update
        ])
      end
    end

    # messages
    namespace(:messages) do
      post(:front, constraints: { format: :json })
    end

    # fallback
    get("*path", to: redirect(sign_in_path))
  end

  # -- signed-in --
  def signed_in(role: nil)
    if role.nil?
      Clearance::Constraints::SignedIn.new
    else
      Clearance::Constraints::SignedIn.new do |user_rec|
        User::Repo.map_role(user_rec).name == role
      end
    end
  end

  constraints(signed_in(role: :supplier)) do
    resources(:cases, controller: "cases/supplier", only: %i[
      index
      new
      create
    ])
  end

  constraints(signed_in(role: :dhs)) do
    resources(:cases, controller: "cases/dhs", only: %i[
      index
      edit
      update
    ])
  end

  constraints(signed_in(role: :enroller)) do
    resources(:cases, controller: "cases/enroller", only: %i[
      index
      show
    ])
  end

  constraints(signed_in(role: :cohere)) do
    resources(:cases, only: %i[
      index
      edit
      update
    ])
  end

  constraints(Clearance::Constraints::SignedIn.new) do
    cases_path = "/cases"

    # root
    root(to: redirect(cases_path))

    # users
    scope(module: "users") do
      delete("/sign-out", to: "sessions#destroy")
    end

    # fallback
    get("*path", to: redirect(cases_path), constraints: ->(req) {
      req.path.exclude? "rails/active_storage"
    })
  end
end
