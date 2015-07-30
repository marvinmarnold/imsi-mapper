class CreateStingrayReadings < ActiveRecord::Migration
  def change
    create_table :stingray_readings do |t|
      t.datetime :observed_at
      t.string :version
      t.decimal :lat, :precision => 15, :scale => 10, :default => 0.0
      t.decimal :long, :precision => 15, :scale => 10, :default => 0.0
      t.integer :threat_level

      t.timestamps null: false
    end
  end
end
