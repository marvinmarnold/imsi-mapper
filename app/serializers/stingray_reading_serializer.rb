class StingrayReadingSerializer < ActiveModel::Serializer
  attributes :location, :observed_at, :threat_level
  attribute :med_res_long, :key => :longitude
  attribute :med_res_lat, :key => :latitude
end
