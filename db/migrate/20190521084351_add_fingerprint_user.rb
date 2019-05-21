class AddFingerprintUser < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :fingerprint, :integer
  end
end
