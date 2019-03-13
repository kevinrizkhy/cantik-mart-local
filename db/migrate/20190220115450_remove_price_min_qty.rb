class RemovePriceMinQty < ActiveRecord::Migration[5.2]
  def change
  	remove_column :supplier_items, :min_qty
  	remove_column :supplier_items, :price
  end
end
