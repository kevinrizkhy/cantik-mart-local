class CreateController < ActiveRecord::Migration[5.2]
  def change
    create_table :controllers do |t|
    	t.string :name, null: false
    end
  end
end
