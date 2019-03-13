class AddColumnOrder < ActiveRecord::Migration[5.2]
  def change
  	add_column :orders, :date_paid_off, :datetime
  end
end
