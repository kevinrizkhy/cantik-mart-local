class AddColumnStore < ActiveRecord::Migration[5.2]
  def change
  	add_column :stores, :cash, :float, null: false, default: 1000000000
  	add_column :stores, :equity, :float, null: false, default: 1000000000
  	add_column :stores, :debt, :float, null: false, default: 0
  	add_column :stores, :receivable, :float, null: false, default: 0
  end
end
