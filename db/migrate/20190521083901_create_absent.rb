class CreateAbsent < ActiveRecord::Migration[5.2]
  def change
    create_table :absents do |t|
    	t.references :user, null: false, foreign_key: true
    	t.timestamp :check_in
    	t.timestamp :check_out
    	t.timestamp :overtime_in
    	t.timestamp :overtime_out
    end
  end
end
