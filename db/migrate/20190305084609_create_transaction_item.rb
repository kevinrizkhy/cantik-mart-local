class CreateTransactionItem < ActiveRecord::Migration[5.2]
  def change
    create_table :transaction_items do |t|
    	t.references :item, foreign_key: true, null: false
    	t.references :transaction, foreign_key: true, null: false
    	t.integer :price, null: false
    	t.integer :discount, default: 0
    	t.integer :quantity, null: false
    	t.datetime :date_created
        t.integer :retur
        t.integer :replace
        t.string :reason

    	t.timestamps
    end
  end
end
