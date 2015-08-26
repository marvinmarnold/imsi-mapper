require 'rails_helper'

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

    # cc-todo: very basic test of api GET covered by other tests,
    # but might help reveal problems quickly if we break the basics
    it 'returns the JSON representation of that reading' do
      post '/stingray_readings', :stingray_reading => test_params

      reading_json = get_json response
      expect(reading_json.length).to eq(5) # check to make sure the right amount of fields are returned

      #cc-todo: should compare all keys of attrs match database,
      # following doesn't pass as json has strings for lat & long and time fields,
      # while object attributes are decimals and time format
      #expect(json).to include(sr.attributes)

      expect(reading_json['location']).to be_nil
      expect(reading_json['longitude']).to eq(test_long.to_s)
      expect(reading_json['latitude']).to eq(test_lat.to_s)
      expect(reading_json['threat_level']).to eq(test_threat_level)
      expect(reading_json['observed_at'].to_datetime).to eq(test_observed_at.to_datetime)
    end
  end

  context "when a few stingray readings are created" do
    before(:context) do
      @num_to_test = 3
      StingrayReading.delete_all
      FactoryGirl.create_list(:stingray_reading, @num_to_test)
    end

    it 'returns the proper precision without a token' do
      # without token, expect only 3 decimal places
      get '/stingray_readings'
      reading_json = get_json response

      expect(reading_json.length).to eq(@num_to_test)
      reading_json.each do |reading|
        expect(reading).to include('latitude','longitude')
        lat = reading["latitude"]
        expect(lat).to match(/^[-]*\d+.\d{,3}$/)

        long = reading["longitude"]
        expect(long).to match(/^[-]*\d+.\d{,3}$/)

        expect(reading["unique_token"]).not_to be_empty
      end
    end

    it 'returns the proper precision with a token' do
      key = ApiKey.create!

      get '/stingray_readings',  nil, {'Authorization' => "Token token=#{key.access_token}"}
      reading_json = get_json response
      expect(reading_json.length).to eq(@num_to_test)

      reading_json.each do |reading|
        expect(reading).to include('latitude','longitude')

        lat = reading["latitude"]
        expect(lat).to match(/^[-]?\d+.\d{,5}$/)

        long = reading["longitude"]
        expect(long).to match(/^[-]?\d+.\d{,5}$/)
      end
    end
  end


  context "when a few safe and dangerous readings have been created" do
    before(:context) do
      StingrayReading.delete_all
      @num_dangerous_create = 10
      @num_safe_create = 3
      FactoryGirl.create_list(:dangerous_stingray_reading, @num_dangerous_create)
      FactoryGirl.create_list(:safe_stingray_reading, @num_safe_create)
    end

    it 'only returns readings above 15 (red and skull) when no token sent' do
      get '/stingray_readings'
      reading_json = get_json response
      expect(reading_json.length).to eq(@num_dangerous_create)

      reading_json.each do |reading|
        expect(reading).to include('threat_level')
        level = reading["threat_level"]

        expect(level).to be >= 15
      end
    end

    it 'returns readings of all levels when token sent' do
      key = ApiKey.create!
      expect(key.attributes.keys).to include('access_token')

      get '/stingray_readings',  nil, {'Authorization' => "Token token=#{key.access_token}"}

      reading_json = JSON.parse(response.body)
      expect(reading_json.length).to eq(@num_safe_create + @num_dangerous_create)

      reading_json.each do |reading|
        expect(reading).to include('threat_level')
        level = reading["threat_level"]

        expect(level).to be >= 0
        expect(level).to be <= 20
      end
    end
  end

  def get_json(response)
    expect(response).to be_success            # test for the 200 status-code
    JSON.parse(response.body)
  end
end