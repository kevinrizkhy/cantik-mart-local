class CreateReport < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
    	t.references :store, foreign_key: true, null: false

  		t.float :cash, null: false, default: 0
  		t.float :stock_value, null: false, default: 0
    	t.float :receivable, null: false, default: 0
    	t.float :asset, null: false, default: 0

		  t.float :capital, null: false, default: 0
    	t.float :debt, null: false, default: 0
		  t.float :outcome, null: false, default: 0
		  t.float :sales, null: false, default: 0

      t.timestamps

    end
  end
end
