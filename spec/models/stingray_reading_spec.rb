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

    context 'when a StingrayReading is created' do
      StingrayReading.delete_all
      test_observed_at = "Tue, 25 Aug 2015 17:56:05 -0500"
      test_lat = "35.084"
      test_long = "-85.751"

      test_params = {
        lat: test_lat,
        long: test_long,
        observed_at: test_observed_at
      }

      stingray_reading = FactoryGirl.create(:stingray_reading, test_params)

      it 'tries to convert times to standard format' do
        expect(stingray_reading.observed_at).to eq(test_observed_at.to_datetime.in_time_zone)
      end

      it 'truncates the address to the 100s block of a street' do
        expect(stingray_reading.location).to eq("The 1000 block of Ellis Cove Rd, South Pittsburg, 37380, Tennessee, United States")
        expect(stingray_reading.region).to eq("Tennessee")
      end
    end

  # pending "add some examples to (or delete) #{__FILE__}"
end

