module Service
  class Container < ActiveSupport::CurrentAttributes
    # -- includes --
    include Service::Definition

    # -- services --
    # -- services/web
    single(Settings)
    single(Events::DispatchAll)

    # -- services/domain
    single(User::Repo)
    single(Partner::Repo)

    # -- services/external
    builds(Redis)
  end
end
