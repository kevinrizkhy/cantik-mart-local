class AddColumnNominalIntoReturItems < ActiveRecord::Migration[5.2]
  def change
    add_column :retur_items, :nominal, :integer, default: 0, null: false
  end
end
