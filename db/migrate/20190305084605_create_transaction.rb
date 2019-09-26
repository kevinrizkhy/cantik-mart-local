class CreateTransaction < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
    	t.string  :invoice, null: false
    	t.references :user, foreign_key: true, null: false
    	t.references :member, foreign_key: true
    	t.float :total, null: false
    	t.float :discount, default: 0
    	t.float :grand_total, null: false
    	t.integer :items, null: false
    	t.integer :payment_type, default: 1
    	t.integer :bank, default: 0
    	t.float :edc_inv, default: 0
        t.timestamp :date_created, null: false
        t.float :hpp_total, null: false, default: 0

        t.timestamps
    end
    add_reference :complains, :transaction, null: false
  end
end
