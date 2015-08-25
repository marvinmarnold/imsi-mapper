require 'spec_helper'

##
# API spec
#
# run via: bundle exec rspec


describe "StingrayReadings API" do

  context "when a user wants to post a new stingay_reading" do
    test_lat = 29.94235
    test_long = -90.07869
    test_observed_at = "Tue, 25 Aug 2015 22:29:57 UTC +00:00"
    test_version = "0.1.34-alpha-b00"
    test_threat_level = 5

    test_params = {
      lat: test_lat,
      long: test_long,
      observed_at: test_observed_at,
      version: test_version,
      threat_level: test_threat_level
    }

    # it 'truncates the address to the 100s block of a street' do
    #   StingrayReading.delete_all
    #   sr  = FactoryGirl.create(:stingray_reading, :lat => "35.084", :long => "-85.751")

    #   expect(sr).to be_valid
    #   expect(sr.location).to eq("The 1000 block of Ellis Cove Rd, South Pittsburg, 37380, Tennessee, United States")

    #   # without token, expect only 3 decimal places
    #   get '/stingray_readings'
    #   expect(response).to be_success            # test for the 200 status-code
    #   json = JSON.parse(response.body)
    #   expect(json.length).to eq(1)
    #   json.each do |reading|
    #     expect(reading).to include('location')
    #     expect("The 1000 block of Ellis Cove Rd, South Pittsburg, 37380, Tennessee, United States").to match(reading['location'])
    #   end
    # end

    # cc-todo: very basic test of api GET covered by other tests,
    # but might help reveal problems quickly if we break the basics
    # it 'creating a reading directly in the db returns the value via the API' do
    #   StingrayReading.delete_all
    #   sr  = FactoryGirl.build(:stingray_reading, test_params)
    #   expect(sr).to be_valid

    #   post '/stingray_readings', {stingray_reading: test_params}

    #   expect(response).to be_success            # test for the 200 status-code
    #   reading_json = JSON.parse(response.body)
    #   expect(reading_json.length).to eq(5) # check to make sure the right amount of fields are returned

    #   #cc-todo: should compare all keys of attrs match database,
    #   # following doesn't pass as json has strings for lat & long and time fields,
    #   # while object attributes are decimals and time format
    #   #expect(json).to include(sr.attributes)

    #   expect(reading_json['location']).to be_nil
    #   expect(reading_json['longitude']).to eq(test_long.to_s)
    #   expect(reading_json['latitude']).to eq(test_lat.to_s)
    #   expect(reading_json['threat_level']).to eq(test_threat_level)
    #   expect(reading_json['observed_at'].to_datetime).to eq(test_observed_at.to_datetime)
    # end

    # it 'reverse geocodes the location and region when we use the API to post a reading' do
    #   post "/stingray_readings", :stingray_reading => test_params
    #   json = JSON.parse(response.body)
    #   #STDERR.puts "got json: #{json}"
    #   expect(response.status).to be == 201            # test for the 200 status-code
    #   #STDERR.puts json.inspect

    #   # give it a second to geocode, then get it:
    #   sleep(1)
    #   expect(assigns(:stingray_reading).location).to eq('The 2800 block of Thalia St, New Orleans, 70113, Louisiana, United States')
    #   expect(assigns(:stingray_reading).region).to match("Louisiana")
    # end
  end

  # context "when a few stingray readings are created" do
  #   StingrayReading.delete_all
  #   num_to_test = 3
  #   readings = FactoryGirl.create_list(:stingray_reading, num_to_test)
  #   readings.each do |r|
  #       r.reverseGeocode
  #   end

  #   it 'returns the proper precision without a token' do
  #     # without token, expect only 3 decimal places
  #     get '/stingray_readings'
  #     expect(response).to be_success            # test for the 200 status-code
  #     json = JSON.parse(response.body)
  #     expect(json.length).to eq(10)
  #     json.each do |reading|
  #       expect(reading).to include('latitude','longitude')
  #       #STDERR.puts reading
  #       lat = reading["latitude"]
  #       expect(lat).to match(/^[-]*\d+.\d{,3}$/)

  #       long = reading["longitude"]
  #       expect(long).to match(/^[-]*\d+.\d{,3}$/)

  #       expect(reading["unique_token"]).not_to be_empty
  #       # STDERR.puts("unique token: #{reading["unique_token"]}")
  #     end

  #     it 'returns the proper precision with a token' do
  #       key = ApiKey.create!

  #       get '/stingray_readings',  nil, {'Authorization' => "Token token=#{key.access_token}"}
  #       json = JSON.parse(response.body)
  #       expect(json.length).to eq(num_to_test)
  #       json.each do |reading|
  #         #STDERR.puts reading
  #         expect(reading).to include('latitude','longitude')
  #         lat = reading["latitude"]
  #         expect(lat).to match(/^[-]?\d+.\d{,5}$/)
  #         long = reading["longitude"]
  #         expect(long).to match(/^[-]?\d+.\d{,5}$/)
  #       end
  #     end
  # end


  # context "when a few safe and dangerous readings have been created" do
  #   StingrayReading.delete_all

  #   num_dangerous_create = 10
  #   num_safe_create = 3

  #   FactoryGirl.create_list(:dangerous_stingray_reading, num_dangerous_create)
  #   FactoryGirl.create_list(:safe_stingray_reading, num_dangerous_create)

  #   it 'only returns readings above 15 (red and skull) when no token sent' do
  #     get '/stingray_readings'
  #     expect(response).to be_success            # test for the 200 status-code
  #     json = JSON.parse(response.body)
  #     expect(json.length).to eq(num_dangerous_create)
  #     json.each do |reading|
  #       expect(reading).to include('threat_level')
  #       level = reading["threat_level"]
  #       expect(level).to be >= 15
  #     end
  #   end

  #   it 'returns readings of all levels when token sent' do
  #     key = ApiKey.create!
  #     expect(key.attributes.keys).to include('access_token')

  #     get '/stingray_readings',  nil, {'Authorization' => "Token token=#{key.access_token}"}

  #     expect(response).to be_success            # test for the 200 status-code
  #     json = JSON.parse(response.body)
  #     expect(json.length).to eq(num_safe_create + num_dangerous_create)
  #     json.each do |reading|
  #       expect(reading).to include('threat_level')
  #       level = reading["threat_level"]
  #       expect(level).to be >= 0
  #       expect(level).to be <= 20
  #     end
  #   end
  # end

end