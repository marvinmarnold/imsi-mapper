class PublicStingrayReadingSerializer < ActiveModel::Serializer
  attributes :location, :observed_at, :threat_level
  attribute :low_res_long, :key => :longitude
  attribute :low_res_lat, :key => :latitude
end