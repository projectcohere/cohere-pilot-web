class AddClassificationToDocuments < ActiveRecord::Migration[6.0]
  def change
    change_table(:documents) do |t|
      t.integer(:classification, default: 0)
      t.index(:classification)
      t.remove_index(column: :source_url, unique: true)
    end

    reversible do |change|
      change.up do
        change_column_null(:documents, :source_url, true)
      end

      change.down do
        change_column_null(:documents, :source_url, false, "")
      end
    end
  end
end
