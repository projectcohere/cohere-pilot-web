class User < ApplicationRecord
  include Clearance::User

  # -- associations --
  belongs_to(:organization, polymorphic: true, optional: true)
end
