class AddChangeColStoreQty < ActiveRecord::Migration[5.2]
  def change
  	change_column :transaction_items, :quantity, :float
  	change_column :store_items, :stock, :float
  	change_column :transaction_items, :quantity, :float
  	add_column :stores, :bank, :bigint, null: false, default: 0
  	add_column :stores, :grand_total_card_before, :bigint, null: false, default: 0
	add_column :store_balances, :bank, :bigint, null: false, default: 0
  	change_column :orders, :discount_percentage, :float
  	change_column :order_items, :ppn, :float
  end
end
