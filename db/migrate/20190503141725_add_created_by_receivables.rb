class AddCreatedByReceivables < ActiveRecord::Migration[5.2]
  def change
  	add_column :receivables, :to_user, :integer, null: false, default: 1
  end
end
