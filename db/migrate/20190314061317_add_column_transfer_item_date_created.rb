class AddColumnTransferItemDateCreated < ActiveRecord::Migration[5.2]
  def change
  	add_column :transaction_items, :date_created, :timestamp
  end
end
