class CreateGrocierItem < ActiveRecord::Migration[5.2]
  def change
    create_table :grocer_items do |t|
    	t.references :item, foreign_key: true, null: false
    	t.integer :min, null: false
    	t.integer :max, null: false
    	t.float :price, null: false
        t.float :discount, null: false, default: 0
    	
    	t.timestamps
    end
  end
end
