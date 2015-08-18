class AddLowResLatLongToStingrayReadings < ActiveRecord::Migration
  
  def change
    add_column :stingray_readings, :med_res_lat, :decimal, precision: 15, scale: 5, default: 0.0
    add_column :stingray_readings, :med_res_long, :decimal, precision: 15, scale: 5, default: 0.0

    add_column :stingray_readings, :low_res_lat, :decimal, precision: 13, scale: 3, default: 0.0
    add_column :stingray_readings, :low_res_long, :decimal, precision: 13, scale: 3, default: 0.0
  
  end
  
end
