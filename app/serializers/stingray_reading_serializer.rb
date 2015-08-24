class StingrayReadingSerializer < ActiveModel::Serializer
  attributes :location, :observed_at, :threat_level
  attribute :long, :key => :longitude
  attribute :lat, :key => :latitude
end
