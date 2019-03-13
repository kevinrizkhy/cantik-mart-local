class AddColumnDateOrderInv < ActiveRecord::Migration[5.2]
  def change
  	add_column :order_invs, :date_paid, :date
  end
end
