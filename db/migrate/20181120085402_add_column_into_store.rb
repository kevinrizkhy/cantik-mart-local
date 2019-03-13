class AddColumnIntoStore < ActiveRecord::Migration[5.2]
  def change
    add_column :stores, :store_type, :integer, default: 0
  end
end
