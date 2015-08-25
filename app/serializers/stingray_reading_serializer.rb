class StingrayReadingSerializer < ActiveModel::Serializer
  attributes :unique_token, :location, :observed_at, :threat_level, :region
  attribute :med_res_long, :key => :longitude
  attribute :med_res_lat, :key => :latitude
end
