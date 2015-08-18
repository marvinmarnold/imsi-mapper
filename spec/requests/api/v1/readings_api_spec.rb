
require 'spec_helper'

##
# API spec
#
# run via: bundle exec rspec

describe "StingrayReadings API" do
  it 'creating a reading returns it via the API' do
    
    #FactoryGirl.create_list(:stingray_reading, 10)
    sr  = FactoryGirl.create(:stingray_reading, :lat => "35.084", :long => "-85.751")
    sr.reverseGeocode
    sr.save
    
    expect(sr).to be_valid
    
    get '/stingray_readings/' # '/api/v1/messages'

    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    expect(json.length).to eq(1) # check to make sure the right amount of messages are returned
    
    expect(json[0]['location']).to eq("1040 Ellis Cove Rd, South Pittsburg, 37380, Tennessee, United States")

    #expect(json).to eq(sr)
    #STDERR.puts json.inspect    
    
    get "/stingray_readings/#{sr.id}"
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    expect(json.length).to eq(1) # check to make sure the right amount of messages are returned
    expect(json[0]['location']).to eq("1040 Ellis Cove Rd, South Pittsburg, 37380, Tennessee, United States")


    #STDERR.puts json[0]['location']
  end

#  it 'geocodes when we use the api to create' do
#  
#  end
  
end