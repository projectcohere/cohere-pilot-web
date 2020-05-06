module Service
  class Container < ActiveSupport::CurrentAttributes
    # -- includes --
    include Service::Definition

    # -- services --
    # -- services/web
    single(Events::DispatchAll)

    # -- services/domain
    single(User::Repo)
    single(Partner::Repo)

    # -- services/infra
    single(Redis)
  end
end
