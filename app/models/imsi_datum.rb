class ImsiDatum < ActiveRecord::Base
	validates :observed_at, :longitude_degrees, :latitude_degrees, :aimsicd_threat_level,
		presence: true
end
