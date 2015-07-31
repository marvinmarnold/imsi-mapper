class StingrayReading < ActiveRecord::Base
  before_create :set_location

private

  def set_location
    l = "Unknown Location"
    require 'net/http'

    uri = URI("http://maps.googleapis.com/maps/api/geocode/xml")
    params = { :latlng => [self.lat, self.long].join(","), :sensor => true }
    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.get_response(uri)

    response_json = Hash.from_xml(response.body) if response.is_a?(Net::HTTPSuccess)
    if response_json["GeocodeResponse"]["result"]
      results = response_json["GeocodeResponse"]["result"]
      results.each do |result|
        if result.is_a?(Hash) && result.has_key?("type") && result["type"] == "postal_code"
          l = result["formatted_address"]
        end
      end
    end

    puts l
    self.location = l;
  end

  def googleMapsEndpointFor(latitude, longitude)
    "http://maps.googleapis.com/maps/api/geocode/xml?latlng=" + latitude + "," + longitude + "&sensor=true"
  end
end
