class CreateStoreItem < ActiveRecord::Migration[5.2]
  def change
    create_table :store_items do |t|
      t.references :store, foreign_key: true, null: false
      t.references :item, foreign_key: true, null: false
      t.integer :stock, null: false, default: 0
      t.integer :min_stock, null: false, default: 0
      t.float :buy, null: false, default: 0
      t.float :sell, null: false, default: 0
      t.float :head_buy, null: false, default: 0
      
      t.timestamps
    end
  end
end
