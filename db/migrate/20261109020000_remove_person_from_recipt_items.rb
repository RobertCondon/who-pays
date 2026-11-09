class RemovePersonFromReciptItems < ActiveRecord::Migration[8.1]
  def change
    remove_reference :recipt_items, :person, index: true
  end
end
