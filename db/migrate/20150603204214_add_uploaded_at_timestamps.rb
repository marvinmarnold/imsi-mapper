class AddUploadedAtTimestamps < ActiveRecord::Migration
  def change
  	change_table :imsi_data do |t|
  		t.datetime :observed_at
  	end
  	 change_table :wifi_data do |t|
  		t.datetime :observed_at
  	end
  end
end
