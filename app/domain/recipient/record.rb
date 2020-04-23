module Recipient
  class Record < ApplicationRecord
    # -- associations --
    has_one(:chat, dependent: :destroy)
    has_many(:cases, dependent: :destroy)

    # -- household ownership --
    enum(household_ownership: Ownership.all)
  end
end
