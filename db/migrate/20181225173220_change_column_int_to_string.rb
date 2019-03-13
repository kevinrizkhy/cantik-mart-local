class ChangeColumnIntToString < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :phone, :string
    change_column :members, :phone, :string
    change_column :stores, :phone, :string
    change_column :suppliers, :phone, :string
  end
end
