class AddColumnCashFlow < ActiveRecord::Migration[5.2]
  def change
  	add_column :cash_flows, :ref_id, :bigint, null: true
  end
end
