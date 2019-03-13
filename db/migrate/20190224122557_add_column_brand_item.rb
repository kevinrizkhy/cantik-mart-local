class AddColumnBrandItem < ActiveRecord::Migration[5.2]
  def change
  	add_column :items, :brand, :string, null: false, default: "DEFAULT BRAND"
  end
end
