class AddColDiscItem < ActiveRecord::Migration[5.2]
  def change
  	add_column :items, :discount, :float, default: 0
  	add_column :grocer_items, :discount, :float, default: 0
  end
end
