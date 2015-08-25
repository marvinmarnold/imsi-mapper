class AddRegionToStingrayReadings < ActiveRecord::Migration
  def change
        add_column :stingray_readings, :region, :string
  end
end
