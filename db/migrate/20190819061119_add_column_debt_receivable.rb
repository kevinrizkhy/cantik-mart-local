class AddColumnDebtReceivable < ActiveRecord::Migration[5.2]
  def change
  	add_column :debts, :due_date, :date
  	add_column :receivables, :due_date, :date
  end
end
