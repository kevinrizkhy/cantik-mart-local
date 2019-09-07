class CreateStore < ActiveRecord::Migration[5.2]
  def change
    create_table :stores do |t|
      t.string :name, null: false, default: "DEFAULT STORE NAME"
      t.string :address, null: false, default: "DEFAULT STORE ADDRESS"
      t.string :phone, null: false, default: 1234567
      t.integer :store_type, null: false, default: 1
      t.float :cash, null: false, default: 100000000
      t.float :equity, null: false, default: 100000000
      t.float :debt, null: false, default: 0
      t.float :receivable, null: false, default: 0

      t.timestamps
    end
    add_reference :users, :store, null: false
  end
end
