class UnlocatedStingrayReadingSerializer < ActiveModel::Serializer
  attributes :unique_token, :observed_at, :threat_level
  attribute :med_res_long, :key => :longitude
  attribute :med_res_lat, :key => :latitude
end
