class AddPaidByToReciptItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :recipt_items, :paid_by, foreign_key: { to_table: :people }
  end
end
