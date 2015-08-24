require 'spec_helper'

##
# API spec
#
# run via: bundle exec rspec
test_lat = 29.94235
test_long = -90.07869
test_observed_at = "Aug 20, 2015 2:38:05 PM"
test_version = "0.1.34-alpha-b00"
test_threat_level = 5
test_params = {
  lat: test_lat,
  long: test_long,
  observed_at: test_observed_at,
  version: test_version,
  threat_level: test_threat_level
}

describe "StingrayReadings API" do

  # cc-todo: very basic test of api GET covered by other tests,
  # but might help reveal problems quickly if we break the basics
  it 'creating a reading directly in the db returns the value via the API' do

    #FactoryGirl.create_list(:stingray_reading, 10)
    sr  = FactoryGirl.build(:stingray_reading, test_params)
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

    reading_json = json[0]
    expect(reading_json['location']).to be_nil
    expest(reading_json['longitude']).to eq(test_long)
    expest(reading_json['latitude']).to eq(test_lat)
    expest(reading_json['version']).to eq(test_version)
    expest(reading_json['threat_level']).to eq(test_threat_level)
    expest(reading_json['observed_at']).to eq(test_observed_at)

    get "/stingray_readings/#{sr.id}"
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    #see above comment: expect(json).to include(sr.attributes)

    expect(json['location']).to eq("The 1000 block of Ellis Cove Rd, South Pittsburg, 37380, Tennessee, United States")

  end


  it 'reverse geocodes the location when we use the API to post readings' do

    sr  = FactoryGirl.create(:stingray_reading, test_params) # does not save to db

    post "/stingray_readings", :stingray_reading => sr
    json = JSON.parse(response.body)
    #STDERR.puts "got json: #{json}"
    expect(response.status).to be == 201            # test for the 200 status-code
    #STDERR.puts json.inspect


    # give it a second to geocode, then get it:
    sleep(1)
    expect(json).to include('id')
    get "/stingray_readings/#{json['id']}"
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    expect(json["location"]).not_to eq('nil')
    expect(json["latitude"]).to eq('nil')
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
      expect(reading).to include('latitude','longitude')
      #STDERR.puts reading
      lat = reading["latitude"]
      expect(lat).to match(/^[-]*\d+.\d{,3}$/)

      long = reading["longitude"]
      expect(long).to match(/^[-]*\d+.\d{,3}$/)
    end

    get '/stingray_readings/',  nil, {'Authorization' => "Token token=#{key.access_token}"}
    json = JSON.parse(response.body)
    expect(json.length).to eq(10)
    json.each do |reading|
      #STDERR.puts reading
      expect(reading).to include('latitude','longitude')
      lat = reading["latitude"]
      expect(lat).to match(/^[-]*\d+.\d{,5}$/)
      long = reading["longitude"]
      expect(long).to match(/^[-]*\d+.\d{,5}$/)

    end

  end

  it 'only returns readings above 15 (red and skull) when no token sent' do

    (1..20).each do |i|
      # we can't use create_list because it sets all the threat levels the same
      sr = FactoryGirl.create(:stingray_reading, :threat_level => rand(15..20))
    end
    (1..10).each do |i|
      sr = FactoryGirl.create(:stingray_reading, :threat_level => rand(0..14))
    end

    get '/stingray_readings/'
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    expect(json.length).to eq(20)
    json.each do |reading|
      expect(reading).to include('threat_level')
      level = reading["threat_level"]
      expect(level).to be >= 15
    end

  end


  it 'returns readings of all levels when token sent' do
    key = ApiKey.create!
    expect(key.attributes.keys).to include('access_token')

    (1..20).each do |i|
      # we can't use create_list because it sets all the threat levels the same
      sr = FactoryGirl.create(:stingray_reading, :threat_level => rand(15..20))
    end
    (1..10).each do |i|
      sr = FactoryGirl.create(:stingray_reading, :threat_level => rand(0..14))
    end

    get '/stingray_readings/',  nil, {'Authorization' => "Token token=#{key.access_token}"}

    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    expect(json.length).to eq(30)
    json.each do |reading|
      expect(reading).to include('threat_level')
      level = reading["threat_level"]
      expect(level).to be >= 0
      expect(level).to be <= 20
    end

  end

  it 'truncates the address to the 100s block of a street' do

    StingrayReading.delete_all

    sr  = FactoryGirl.build(:stingray_reading, :lat => "35.084", :long => "-85.751")
    sr.reverseGeocode
    sr.save

    expect(sr).to be_valid
    expect(sr.location).to eq("The 1000 block of Ellis Cove Rd, South Pittsburg, 37380, Tennessee, United States")

    # without token, expect only 3 decimal places
    get '/stingray_readings/'
    expect(response).to be_success            # test for the 200 status-code
    json = JSON.parse(response.body)
    expect(json.length).to eq(1)
    json.each do |reading|
      expect(reading).to include('location')
      expect("The 1000 block of Ellis Cove Rd, South Pittsburg, 37380, Tennessee, United States").to match(reading['location'])
    end
  end


end