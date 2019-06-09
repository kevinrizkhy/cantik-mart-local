class CreateGrocierItem < ActiveRecord::Migration[5.2]
  def change
    create_table :grocer_items do |t|
    	t.references :item, foreign_key: true, null: false
    	t.integer :min, null: false
    	t.integer :max, null: false
    	t.float :price, null: false
    add_column :items, :buy_grocer, :integer, default: 0
    end
  end
end
