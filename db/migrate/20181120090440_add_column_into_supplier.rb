class AddColumnIntoSupplier < ActiveRecord::Migration[5.2]
  def change
    add_column :suppliers, :supplier_type, :integer, default: 0
  end
end
