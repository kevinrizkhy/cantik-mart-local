class Orderinv < ActiveRecord::Migration[5.2]
  def change
  	create_table :order_invs do |t|
	  	t.string :invoice, null: false
	  	t.integer :nominal, null: false
	  	t.references :order, foreign_key: true, null:false
	 end
  end
end
