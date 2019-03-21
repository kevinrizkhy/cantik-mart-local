class AddColumnOutcome < ActiveRecord::Migration[5.2]
  def change
  	add_column :outcomes, :outcome_type, :integer, null: false, default: 4
  end
end
