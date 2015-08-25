class PublicNearbyReadingSerializer < ActiveModel::Serializer
  attributes :unique_token, :observed_at
end
