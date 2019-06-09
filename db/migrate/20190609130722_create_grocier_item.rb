class CreateGrocierItem < ActiveRecord::Migration[5.2]
  def change
    create_table :grocier_items do |t|
    	t.references :item, foreign_key: true, null: false
    	t.integer :min, null: false
    	t.integer :max, null: false
    	t.float :price, null: false
    end
  end
end
