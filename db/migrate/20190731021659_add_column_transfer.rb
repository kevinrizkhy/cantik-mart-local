class AddColumnTransfer < ActiveRecord::Migration[5.2]
  def change
  	add_column :transfers, :description, :string
  end
end
