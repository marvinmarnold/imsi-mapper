class AddLocationToStingrayReadings < ActiveRecord::Migration
  def change
    add_column :stingray_readings, :location, :string
  end
end
