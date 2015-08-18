
require 'spec_helper'

##
# API spec
#
# run via: bundle exec rspec

describe "StingrayReadings API" do
  
  # cc-todo: very basic test of api GET covered by other tests, 
  # but might help reveal quickly if we break the basics
  it 'creating a reading directly in the db returns the value via the API' do
    
    #FactoryGirl.create_list(:stingray_reading, 10)
    sr  = FactoryGirl.build(:stingray_reading, :lat => "35.084", :long => "-85.751")
    sr.reverseGeocode
    sr.save
    
    expect(sr).to be_valid
    
    get '/stingray_readings/' # '/api/v1/messages'

    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    expect(json.length).to eq(1) # check to make sure the right amount of messages are returned
    
    #cc-todo: should compare all keys of attrs match database,
    # following doesn't pass as json has strings for lat & long and time fields,
    # while object attributes are decimals and time format
    #expect(json).to include(sr.attributes)

    # for now, just compare location string:
    expect(json[0]['location']).to eq("1040 Ellis Cove Rd, South Pittsburg, 37380, Tennessee, United States")
 
    
    get "/stingray_readings/#{sr.id}"
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    #see above comment: expect(json).to include(sr.attributes)

    expect(json['location']).to eq("1040 Ellis Cove Rd, South Pittsburg, 37380, Tennessee, United States")
    
  end


  it 'reverse geocodes the location when we use the API to post readings' do
    
    sr  = FactoryGirl.build(:stingray_reading) # does not save to db 
    
    #STDERR.puts sr.attributes
    post "/stingray_readings", :stingray_reading => sr.attributes
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    #STDERR.puts json.inspect  
 
    
    # give it a second to geocode, then get it:
    sleep(1)
    expect(json).to include('id')
    get "/stingray_readings/#{json['id']}"
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    expect(json["location"]).not_to eq('nil')
    #STDERR.puts json.inspect  
    
    #expect(json['location']).to eq("1040 Ellis Cove Rd, South Pittsburg, 37380, Tennessee, United States")

  end
  
  it 'shows the proper precision with and without a token' do
    
    #key = FactoryGirl.build(:api_key) # create a token in the test db
    
    key = ApiKey.create!

    #STDERR.puts "token is: #{key.access_token}"
    
    FactoryGirl.create_list(:stingray_reading,10)
    
    # without token, expect only 3 decimal places
    get '/stingray_readings/'
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    expect(json.length).to eq(10)
    json.each do |reading|
      expect(reading).to include('lat','long')
      lat = reading["lat"]
      expect(lat).to match(/^\d+.\d{,3}$/)
    end
    
    get '/stingray_readings/',  nil, {'Authorization' => "Token token=#{key.access_token}"}
    json = JSON.parse(response.body)
    expect(json.length).to eq(10)
    json.each do |reading|
      #STDERR.puts reading
      expect(reading).to include('lat','long')
      lat = reading["lat"]
      expect(lat).to match(/^\d+.\d{,5}$/)
    end
    
  end
  
  it 'only returns readings above 15 (red and skull)' do
    
    
    FactoryGirl.create_list(:stingray_reading,10)
    get '/stingray_readings/'
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    expect(json.length).to eq(10)
    json.each do |reading|
      expect(reading).to include('threat_level')
      level = reading["threat_level"]
      expect(level).to be >= 15
    end
  
  end
  
  
  
end