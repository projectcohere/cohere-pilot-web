class AddSearchColumnsToRecipient < ActiveRecord::Migration[6.0]
  def change
    enable_extension("pg_trgm")

    # rails' awkward way of expressing:
    # CREATE INDEX by_full_name ON recipients
    # USING gin ((first_name || ' ' || last_name) gin_trgm_ops);
    add_index(:recipients,
      "(first_name || ' ' || last_name) gin_trgm_ops",
      using: :gin,
      name: "by_full_name"
    )
  end
end
