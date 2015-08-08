class AddFlagToStingrayReadings < ActiveRecord::Migration
  def change
    add_column :stingray_readings, :flag, :integer 
  end
end
