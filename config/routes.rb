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

  signed_in(role: :supplier) do |c|
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

    fallback(:supplier, to: "/cases", constraints: c)
  end

  signed_in(role: :governor) do |c|
    resources(:cases, id: /\d+/, only: %i[
      edit
      update
    ]) do
      get("/",
        on: :collection,
        action: :index,
      )

      get("/queue",
        on: :collection,
        action: :queue,
        constraints: merge(c, query(scope: /^(assigned|queued)?$/)),
      )

      get("/",
        on: :collection,
        to: redirect("/cases/queue")
      )

      resources(:assignments, only: %i[
        create
      ])
    end

    fallback(:governor, to: "/cases/queue", constraints: c)
  end

  signed_in(role: :enroller) do |c|
    resources(:cases, id: /\d+/, only: %i[
      show
    ]) do
      get("/",
        on: :collection,
        action: :index,
      )

      get("/queue",
        on: :collection,
        action: :queue,
        constraints: merge(c, query(scope: /^(assigned|queued)?$/)),
      )

      get("/",
        on: :collection,
        to: redirect("/cases/queue")
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

    fallback(:enroller, to: "/cases/queue", constraints: c)
  end

  signed_in(role: :cohere) do |c|
    # -- cases --
    resources(:cases, id: /\d+/, only: %i[
      edit
      update
      show
      destroy
    ]) do
      get("/",
        on: :collection,
        action: :index,
        constraints: merge(c, query(scope: /^(all|open|completed)?$/)),
      )

      get("/queue",
        on: :collection,
        action: :queue,
        constraints: merge(c, query(scope: /^(assigned|queued)?$/)),
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
    fallback(:cohere, to: "/cases/queue", constraints: c)
  end

  # -- development --
  if Rails.env.development?
    require "sidekiq/web"
    mount(Sidekiq::Web => "/sidekiq")
  end
end
