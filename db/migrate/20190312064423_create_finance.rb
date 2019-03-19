class CreateFinance < ActiveRecord::Migration[5.2]
  def change
    create_table :finances do |t|
    	t.references :user, foreign_key: true, null: false
    	t.references :store, foreign_key: true, null: false
    	t.float :nominal, null: false
    	t.integer :finance_type, null: false, default: 1
    	t.timestamp :date_created
    	t.string :description
    end
  end
end
