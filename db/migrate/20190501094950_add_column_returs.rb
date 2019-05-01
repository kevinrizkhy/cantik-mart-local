class AddColumnReturs < ActiveRecord::Migration[5.2]
  def change
  	add_column :retur_items, :ref_id, :integer
  end
end
