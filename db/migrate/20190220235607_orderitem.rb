class Orderitem < ActiveRecord::Migration[5.2]
  def change
  	create_table :order_items do |t|
  		t.integer :receive
	  	t.integer :quantity, null: false
	  	t.integer :price, null: false
	  	t.references :item, foreign_key: true, null:false
	  	t.references :order, foreign_key: true, null:false
  	end
  end
end
