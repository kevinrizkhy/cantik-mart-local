class CreateTableCapital < ActiveRecord::Migration[5.2]
  def change
    create_table :capitals do |t|
    	t.references :store, null: false, foreign_key: true
    	t.references :user, null: false, foreign_key: true
    	t.float :nominal, null: false
    	t.timestamp :date_created, null: false
    	t.string :description, null: false
    	
    	t.timestamps
    end
  end
end
