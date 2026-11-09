class AddReciptTables < ActiveRecord::Migration[8.1]
  def up
    create_table :recipt do |t|
      t.integer :total
      t.integer :total_paid
    end

    create_table :person do |t|
      t.string :name
    end

    create_table :recipt_item do |t|
      t.references :recipt
      t.references :person
      t.string :name
      t.integer :price
      t.boolean :paid, default: false
    end
  end

  def down
    drop_table :recipt_item
    drop_table :person
    drop_table :recipt
  end
end
