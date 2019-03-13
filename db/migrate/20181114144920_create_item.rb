class CreateItem < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.string :code, null: false, default: 'DEFAULT_CODE'
      t.string :name, null: false, default: 'DEFAULT_NAME'
      t.integer :stock, null: false, default: 0
      t.integer :buy, null: false, default: 1
      t.integer :sell, null: false, default: 1
      t.references :item_cat, null: false, foreign_key: true
    end
  end
end
