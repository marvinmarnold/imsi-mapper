class PublicStingrayReadingSerializer < ActiveModel::Serializer
  attributes :unique_token, :location,  :region, :observed_at, :threat_level
  attribute :low_res_long, :key => :longitude
  attribute :low_res_lat, :key => :latitude
end
