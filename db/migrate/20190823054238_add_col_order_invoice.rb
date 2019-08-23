class AddColOrderInvoice < ActiveRecord::Migration[5.2]
  def change
  	add_reference :invoice_transactions, :user, foreign_key: true
  end
end
