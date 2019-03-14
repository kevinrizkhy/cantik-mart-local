class AddHppTrxItems < ActiveRecord::Migration[5.2]
  def change
  	add_column :transactions, :hpp_total, :integer
  end
end
