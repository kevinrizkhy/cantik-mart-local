class CreateSupplier < ActiveRecord::Migration[5.2]
  def change
    create_table :suppliers do |t|
      t.string :pic, null: false, default: "DEFAULT NAME SUPPLIER"
      t.string :address, null: false, default: "DEFAULT ADDRESS SUPPLIER"
      t.bigint :phone, null: false, default: 123456789

    end
  end
end
