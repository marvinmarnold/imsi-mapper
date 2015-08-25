require 'rails_helper'



##
# model spec for StingrayReading
#
# run via: bundle exec rspec

#RSpec.describe Stingray_reading, type: :model do
RSpec.describe StingrayReading, :type => :model do

    it "has a valid factory" do
        expect(FactoryGirl.create(:stingray_reading)).to be_valid
    end

    context "with 1 readings" do
        reading = FactoryGirl.build(:stingray_reading, :lat => "35.0841592", :long => "-85.7512524")
        
        
=begin
# not using google geocoder 
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
=end
        it "handles geocodes with mapbox" do
            reading.useMapboxGeocoder
            reading.reverseGeocode
            expect(reading.location).to eq("The 1000 block of Ellis Cove Rd, South Pittsburg, 37380, Tennessee, United States") 
            expect(reading.region).to eq("Tennessee")
        end
        
    end


    context "with x readings" do

        

    end

  # pending "add some examples to (or delete) #{__FILE__}"
end
