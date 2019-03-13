class CreateSupplierItem < ActiveRecord::Migration[5.2]
  def change
    create_table :supplier_items do |t|
      t.references :supplier, foreign_key: true, null: false
      t.references :item, foreign_key: true, null: false
      t.integer :price, null: false
      t.integer :min_qty
      t.timestamps
    end
  end
end
