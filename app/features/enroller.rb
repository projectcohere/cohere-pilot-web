class Enroller < ::Entity
  # -- props --
  prop(:id)
  prop(:name)

  # -- lifetime --
  define_initialize!
end
