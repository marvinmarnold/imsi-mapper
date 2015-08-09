class AddFlagToStingrayReadings < ActiveRecord::Migration
  def change
    add_column :stingray_readings, :flag, :integer, default: 0
  end
end
