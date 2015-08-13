require 'rails_helper'

#RSpec.describe Stingray_reading, type: :model do
RSpec.describe StingrayReading, :type => :model do
    context "with 0 or more readings" do
        iThreatLevel = rand(15..20)
        reading = StingrayReading.new( version: "1", lat: "35.084", long:"-85.751", threat_level: iThreatLevel, observed_at: Time.now)

        it "handles geocode timeout errors" do
            reading.useFakeTimeoutGoogleGeocoder
            reading.reverseGeocode
            expect(reading.location).to eq("") 
        end

        it "handles geocodes with google" do
            reading.useGoogleGeocoder
            reading.reverseGeocode
            expect(reading.location).to eq("South Pittsburg, TN 37380, USA") 
        end
        reading.location= ""
        it "handles geocodes with mapbox" do
            reading.useMapboxGeocoder
            reading.reverseGeocode
            expect(reading.location).to eq("1040 Ellis Cove Rd, South Pittsburg, 37380, Tennessee, United States") 
        end
        
    end

  # pending "add some examples to (or delete) #{__FILE__}"
end
