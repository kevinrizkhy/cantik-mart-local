class CreateTableCredit < ActiveRecord::Migration[5.2]
  def change
    create_table :credits do |t|
    	t.references :store, null: false, foreign_key: true
    	t.references :user, null: false, foreign_key: true
    	t.float :nominal, null: false
        t.float :deficiency, null: false
    	t.timestamp :date_created, null: false
    	t.string :description, null: false
    	t.integer :ref_id
    	t.integer :finance_type, null: false
    end
  end
end
