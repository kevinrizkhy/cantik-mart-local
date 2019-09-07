class CreateTableAsset < ActiveRecord::Migration[5.2]
  def change
    create_table :assets do |t|
    	t.references :store, null: false, foreign_key: true
    	t.references :user, null: false, foreign_key: true
    	t.float :nominal, null: false
    	t.timestamp :date_created, null: false
    	t.string :description, null: false
    	t.integer :finance_type, null: false
        
        t.timestamps
    end
  end
end
