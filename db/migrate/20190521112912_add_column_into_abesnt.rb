class AddColumnIntoAbesnt < ActiveRecord::Migration[5.2]
  def change
  	add_column :absents,:work_hour,:string, default:"0:0:0"
  	add_column :absents,:overtime_hour,:string, default:"0:0:0"
  end
end
