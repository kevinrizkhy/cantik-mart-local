class AddColumnFinance < ActiveRecord::Migration[5.2]
  def change
  	add_column :finances, :status, :boolean, default: false
  	add_reference :finances, :order
  end
end
