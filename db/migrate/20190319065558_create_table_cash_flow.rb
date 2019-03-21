class CreateTableCashFlow < ActiveRecord::Migration[5.2]
  def change
    create_table :cash_flows do |t|
    	t.references :user, foreign_key: true, null: false
    	t.references :store, foreign_key: true, null: false
    	t.integer :nominal, null: false
    	t.integer :finance_type, null: false, default: 1
    	t.timestamp :date_created
		  t.string :description
    end
  end
end
