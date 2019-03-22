class AddColumnInvCashFlow < ActiveRecord::Migration[5.2]
  def change
  	add_column :cash_flows, :invoice, :string, null: false, default: "-"
  end
end
