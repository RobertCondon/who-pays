class ConventionalizeReciptTables < ActiveRecord::Migration[8.1]
  def change
    # Rails expects plural table names (ReciptItem -> recipt_items).
    rename_table :recipt, :recipts
    rename_table :person, :people
    rename_table :recipt_item, :recipt_items

    # Prices are stored in cents. total / total_paid are derived from items now.
    remove_column :recipts, :total, :integer
    remove_column :recipts, :total_paid, :integer

    add_column :recipts, :venue, :string
    add_column :recipts, :server, :string
    add_column :recipts, :opened_at, :datetime
    add_timestamps :recipts, default: -> { "CURRENT_TIMESTAMP" }

    add_column :recipt_items, :category, :string
    add_column :recipt_items, :position, :integer

    add_index :people, :name, unique: true
  end
end
