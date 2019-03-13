class AddColumnIntoReturItems < ActiveRecord::Migration[5.2]
  def change
    add_column :retur_items, :accept_item, :integer, default: 0
  end
end
