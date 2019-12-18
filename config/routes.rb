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

    # chats
    resource(:chat, only: [:show]) do
      get("/connect", action: :connect)
      get("/join", action: :join)
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
    scope(module: :supplier) do
      resources(:cases, only: %i[
        index
        new
        create
      ])
    end
  end

  constraints(signed_in(role: :dhs)) do
    scope(module: :dhs) do
      resources(:cases, only: %i[
        index
        edit
        update
      ])
    end
  end

  constraints(signed_in(role: :enroller)) do
    scope(module: :enroller) do
      resources(:cases, only: %i[
        index
        show
      ]) do
        patch("/:complete_action",
          as: :complete,
          action: :complete,
          constraints: { complete_action: /approve|deny/ }
        )
      end
    end
  end

  constraints(signed_in(role: :cohere)) do
    scope(module: :cohere) do
      resources(:cases, constraints: { id: /\d+/ }, only: %i[
        edit
        update
        show
      ]) do
        get("/:scope",
          on: :collection,
          action: :index,
          constraints: { scope: /open|completed/ }
        )

        get("/",
          on: :collection,
          to: redirect("/cases/open")
        )

        resources(:referrals, only: %i[
          new
          create
        ])
      end
    end
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
