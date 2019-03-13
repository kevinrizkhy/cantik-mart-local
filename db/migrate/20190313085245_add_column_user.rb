class AddColumnUser < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :salary, :integer, default: 0
  end
end
