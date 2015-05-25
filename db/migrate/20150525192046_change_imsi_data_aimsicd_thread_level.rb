class ChangeImsiDataAimsicdThreadLevel < ActiveRecord::Migration
  def change
  	change_table :imsi_data do |t|
  		t.rename :aimsicd_thread_level, :aimsicd_threat_level
  		t.decimal :latitude_degrees, :precision => 15, :scale => 10, :default => 0.0
  		t.decimal :longitude_degrees, :precision => 15, :scale => 10, :default => 0.0
  	end
  end
end
