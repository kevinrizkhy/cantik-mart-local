class ModTransactionCol < ActiveRecord::Migration[5.2]
  def change
  	add_column :transaction_items, :retur, :integer
  	add_column :transaction_items, :replace, :integer
  	add_column :transaction_items, :reason, :string
  end
end
