class AddColumnStoreItemLimit < ActiveRecord::Migration[5.2]
  def change
  	add_column :store_items, :min_stock, :integer, default: 0, null: false
  end
end
