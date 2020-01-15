Rails.application.routes.draw do
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
      match("/join", via: :get, to: redirect("/chat/invites/new"))
      match("/start/:invitation_token", via: :get, action: :start)
      match("/files", via: :post, action: :files, constraints: ->(req) {
        req.content_type == "multipart/form-data"
      })

      # sessions
      resources(:invites, module: "chats", only: [
        :new,
        :create,
      ]) do
        match("/verify", via: :get, on: :collection, action: :edit)
        match("/", via: :put, on: :collection, action: :update)
      end
    end

    # fallback
    get("*path", to: redirect(sign_in_path), constraints: ->(req) {
      # unclear why we have to constrain to signed out again here, since it
      # be enforced by the enclosing `constraints`. but if we don't all urls
      # for signed-in users infinitely redirect to sign_in_path.
      signed_out = Clearance::Constraints::SignedOut.new
      signed_out.matches?(req) && req.path.exclude?("rails/active_storage")
    })
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

      # chats
      resources(:chats, only: []) do
        post("/files", action: :files, constraints: ->(req) {
          req.content_type == "multipart/form-data"
        })
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
      req.path.exclude?("rails/active_storage")
    })
  end

  # -- development --
  if Rails.env.development?
    require "sidekiq/web"
    mount(Sidekiq::Web => "/sidekiq")
  end

  # -- test --
  if Rails.env.test?
    post("/tests/chat-session", to: "tests#chat_session")
  end
end
