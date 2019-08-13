class AddColumnTransfer < ActiveRecord::Migration[5.2]
  def change
  	add_column :transfers, :description, :string
  	add_reference :transfers, :user, foreign_key: true
  	add_column :transfers, :approved_by,:integer
  	add_column :transfers, :picked_by,:integer
  	add_column :transfers, :confirmed_by,:integer


  	add_reference :orders, :user, foreign_key: true
  	add_column :orders, :received_by,:integer

  	add_reference :returs, :user, foreign_key: true
  	add_column :returs, :picked_by,:integer
  	add_column :returs, :approved_by,:integer
  end
end
