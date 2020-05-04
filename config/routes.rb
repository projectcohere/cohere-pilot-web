require_relative "routes/auth"
require_relative "routes/constraints"
require_relative "routes/fallback"

Rails.application.routes.draw do
  extend Routes::Auth
  extend Routes::Constraints
  extend Routes::Fallback

  # -- signed-out --
  signed_out do |c|
    # stats
    get("/partner/stats", to: "partners/stats#show")

    # users
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
    fallback(:signed_out, to: "/sign-in", constraints: c)
  end

  # -- signed-in --
  signed_in do |_|
    scope(module: :users) do
      delete("/sign-out", to: "sessions#destroy")
    end
  end

  signed_in(role: Role::Source) do |c|
    resources(:cases, id: /\d+/, only: %i[
      index
      new
      create
    ]) do
      get("/select",
        on: :collection,
        action: :select,
        as: :select,
      )
    end

    fallback(Role::Source, to: "/cases", constraints: c)
  end

  signed_in(role: Role::Governor) do |c|
    resources(:cases, id: /\d+/, only: %i[
      index
      edit
      update
    ]) do
      get("/inbox",
        on: :collection,
        action: :queue,
      )

      get("/search",
        on: :collection,
        action: :search,
      )

      resources(:assignments, only: %i[
        create
      ])
    end

    fallback(Role::Governor, to: "/cases", constraints: c)
  end

  signed_in(role: Role::Enroller) do |c|
    resources(:cases, id: /\d+/, only: %i[
      index
      show
    ]) do
      get("/inbox",
        on: :collection,
        action: :queue,
      )

      get("/search",
        on: :collection,
        action: :search,
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

    fallback(Role::Enroller, to: "/cases", constraints: c)
  end

  signed_in(role: Role::Agent) do |c|
    # -- cases --
    resources(:cases, id: /\d+/, only: %i[
      index
      edit
      update
      show
      destroy
    ]) do
      get("/inbox",
        on: :collection,
        action: :queue,
        as: :queue,
      )

      get("/search",
        on: :collection,
        action: :search,
        constraints: merge(c, query(scope: /^(all|active|archived)?$/)),
      )

      patch("/archive",
        on: :member,
        action: :archive,
        as: :archive,
      )

      # -- cases/assignments
      resources(:assignments, only: %i[
        create
      ]) do
        delete("/:partner_id", on: :collection, action: :destroy, as: :destroy)
      end

      # -- cases/referrals
      resources(:referrals, only: %i[
        new
        create
      ]) do
        get("/select",
          on: :collection,
          action: :select,
          as: :select,
        )
      end
    end

    # -- chats --
    resources(:chats, only: []) do
      post("/files",
        action: :files,
        constraints: merge(c, content_type("multipart/form-data")),
      )
    end

    # -- fallback --
    fallback(Role::Agent, to: "/cases", constraints: c)
  end

  # -- development --
  if Rails.env.development?
    require "sidekiq/web"
    mount(Sidekiq::Web => "/sidekiq")
  end
end
