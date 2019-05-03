class AddColumnOrderItem < ActiveRecord::Migration[5.2]
  def change
  	add_column :orders, :editable, :boolean, null: false, default: true
  	add_column :orders, :old_total, :integer, null: false, default: 0
  	add_column :orders, :date_change, :timestamp
  	add_column :order_items, :new_receive, :integer, null: false, default: 0
  end
end
