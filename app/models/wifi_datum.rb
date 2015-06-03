class WifiDatum < ActiveRecord::Base
	validates :observed_at, :longitude_degrees, :latitude_degrees, :num_wifi_hotspots,
		presence: true
end
