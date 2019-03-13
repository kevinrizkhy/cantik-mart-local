class Order < ActiveRecord::Migration[5.2]
  def change
  		create_table :orders do |t|
		  	t.string :invoice, null: false
		  	t.datetime :date_created, null: false
		  	t.datetime :date_receive
		  	t.references :supplier, foreign_key: true, null: false
		  	t.references :store, foreign_key: true, null: false
		  	t.integer :total_items, null: false
		  	t.integer :total, null: false
  		end
  end
end
