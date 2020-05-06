module Recipient
  class Record < ApplicationRecord
    # -- associations --
    has_one(:chat, dependent: :destroy)
    has_many(:cases, dependent: :destroy)

    # -- household --
    enum(household_ownership: Ownership.keys)
    enum(household_proof_of_income: ProofOfIncome.keys)
  end
end
