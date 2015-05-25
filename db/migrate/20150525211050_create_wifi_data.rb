class CreateWifiData < ActiveRecord::Migration
  def change
    create_table :wifi_data do |t|
      t.integer :num_wifi_hotspots
      t.decimal :latitude_degrees, :precision => 15, :scale => 10, :default => 0.0
      t.decimal :longitude_degrees, :precision => 15, :scale => 10, :default => 0.0

      t.timestamps null: false
    end
  end
end
