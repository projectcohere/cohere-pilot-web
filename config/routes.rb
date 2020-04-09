Rails.application.routes.draw do
  # -- signed-out --
  constraints(Clearance::Constraints::SignedOut.new) do
    root_path = "/sign-in"

    # root
    root(to: redirect(root_path), as: :root_signed_out)

    # users
    get("/partner", to: redirect("/sign-in"))
    get("/partner/stats", to: "partners/stats#show")

    scope(module: :users) do
      get("/sign-in", to: "sessions#new")

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
    namespace(:chats) do
      namespace(:sms) do
        post(:inbound)
        post(:status)
      end
    end

    # fallback
    get("*path", to: redirect(root_path), constraints: ->(req) {
      # unclear why we have to constrain to signed out again here, since it
      # is enforced by the enclosing `constraints`. if we don't all urls
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

  constraints(signed_in(role: :governor)) do
    scope(module: :governor) do
      resources(:cases, only: %i[
        edit
        update
      ]) do
        get("/:scope",
          on: :collection,
          action: :index,
          constraints: { scope: /queued|assigned|open/ }
        )

        get("/",
          on: :collection,
          to: redirect("/cases/queued")
        )

        resources(:assignments, only: %i[
          create
        ])
      end
    end
  end

  constraints(signed_in(role: :enroller)) do
    scope(module: :enroller) do
      resources(:cases, only: %i[
        show
      ]) do
        get("/:scope",
          on: :collection,
          action: :index,
          constraints: { scope: /queued|assigned|submitted/ }
        )

        get("/",
          on: :collection,
          to: redirect("/cases/queued")
        )

        patch("/:complete_action",
          as: :complete,
          action: :complete,
          constraints: { complete_action: /approve|deny/ }
        )

        resources(:assignments, only: %i[
          create
        ])
      end
    end
  end

  constraints(signed_in(role: :cohere)) do
    scope(module: :cohere) do
      resources(:cases, constraints: { id: /\d+/ }, only: %i[
        edit
        update
        show
        destroy
      ]) do
        get("/:scope",
          on: :collection,
          action: :index,
          constraints: { scope: /queued|assigned|open|completed/ }
        )

        get("/",
          on: :collection,
          to: redirect("/cases/queued")
        )

        resources(:assignments, only: %i[
          create
        ]) do
          delete("/:partner_id", on: :collection, action: :destroy, as: :destroy)
        end

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
    scope(module: :users) do
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
end
