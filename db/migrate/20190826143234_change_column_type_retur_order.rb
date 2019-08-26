class ChangeColumnTypeReturOrder < ActiveRecord::Migration[5.2]
  def change
  	change_column :receivables, :ref_id, :string
  end
end
