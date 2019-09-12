class AddColStore < ActiveRecord::Migration[5.2]
  def change
  	add_column :stores, :grand_total_before, :bigint, default: 0
  	add_column :items, :local_item, :boolean, default: false
  end
end
