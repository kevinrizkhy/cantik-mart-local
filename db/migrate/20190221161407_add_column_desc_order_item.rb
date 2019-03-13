class AddColumnDescOrderItem < ActiveRecord::Migration[5.2]
  def change
  	add_column :order_items, :description, :string
  end
end
