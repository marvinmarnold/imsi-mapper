require 'rails_helper'

#RSpec.describe Stingray_reading, type: :model do
RSpec.describe StingrayReading, :type => :model do
    context "with 0 or more readings" do
        it "handles geocode timeout errors" do
      
            iThreatLevel = rand(0..5)
            reading = StingrayReading.new( version: "1", lat: "35.084", long:"-85.751", threat_level: iThreatLevel, observed_at: Time.now)
            
            reading.geocodeurl= "http://combiconsulting.com/_things/stingmock.php" # for testing timeout logic

            reading.set_location() 
            
            expect(reading.location).to eq(nil) 
    
        end
        
        
    end

  # pending "add some examples to (or delete) #{__FILE__}"
end
