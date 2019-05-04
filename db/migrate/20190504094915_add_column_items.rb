class AddColumnItems < ActiveRecord::Migration[5.2]
  def change
  	add_column :items, :wholesale, :float, null: false, default: 0
  	add_column :items, :box, :float, null: false, default: 0
  end
end
