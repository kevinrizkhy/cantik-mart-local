class ChangeColumnSupplierPic < ActiveRecord::Migration[5.2]
  def change
  	add_column :suppliers, :name, :string, default: 'DEFAULT NAME SUPPLIER'
  end
end
