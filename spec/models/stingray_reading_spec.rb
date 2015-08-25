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

    it 'tries to convert times to standard format' do
      test_observed_at = "Tue, 25 Aug 2015 17:56:05 -0500"
      stingray_reading = FactoryGirl.create(:stingray_reading, observed_at: test_observed_at)
      expect(stingray_reading.observed_at).to eq(test_observed_at.to_datetime.in_time_zone)
    end

  # pending "add some examples to (or delete) #{__FILE__}"
end
