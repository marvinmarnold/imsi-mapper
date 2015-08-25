require 'rails_helper'

test_reading_lat = 29.94235
test_reading_long = -90.07869

test_params = {
  lat: test_reading_lat,
  long: test_reading_long,
  threat_level: 15
}

describe "Nearby API" do

# cc-todo: DRY this
context 'when there are ten nearby readings' do
     it 'returns those same ten nearby readings' do
        
        StingrayReading.delete_all
        @min = -StingrayReading::NEARBY_RADIUS
        @max = StingrayReading::NEARBY_RADIUS
        (1..10).each do |i| 
            test_params['lat'] = test_reading_lat  + rand(@min..@max)
            test_params['long'] = test_reading_long  + rand(@min..@max)
            test_params['observed_at'] = Time.now
            sr  = FactoryGirl.build(:stingray_reading, test_params)
            sr.reverseGeocode
            sr.save
            
            expect(StingrayReading.find(sr.id)).not_to be_nil # ensure it is in database
            #STDERR.puts "#{sr.lat}, #{sr.long}, #{sr.observed_at}"
        end
            
        key = ApiKey.create!
    
        # pass lat, long, time
        nearby_params = {
            lat: test_reading_lat,
            long: test_reading_long,             
            since: Time.now - 120
        }
        get '/nearby.json', {time_and_space: nearby_params}, { :format => :json }
        expect(response).to be_success            # test for the 200 status-code
        json = JSON.parse(response.body)
        expect(json.length).to eq(10)
        
        #json.each do |sr|
        #    STDERR.puts sr
        #end
        
    end
    
 end
 
 context 'when there are ten readings just outside of the search boundary' do

     it 'returns zero of those  readings as nearby' do
        key = ApiKey.create!
    
        @radius = StingrayReading::NEARBY_RADIUS
    
        StingrayReading.delete_all
        (1..10).each do |i| 
            test_params['lat'] = test_reading_lat + rand((-2*@radius)..(-@radius-0.0001))
            test_params['long'] = test_reading_long + rand(-@radius..@radius)
            sr  = FactoryGirl.build(:stingray_reading, test_params)
            sr.reverseGeocode
            sr.save
            #STDERR.puts "#{sr.lat}, #{sr.long}, #{sr.observed_at}"
            expect(StingrayReading.find(sr.id)).not_to be_nil # ensure it is in database
        end
        
        # pass lat, long, time
        nearby_params = {
            lat: test_reading_lat,
            long: test_reading_long,
            since: Time.now - 120
        }
        get '/nearby.json', {time_and_space: nearby_params}, { :format => :json }
        expect(response).to be_success            # test for the 200 status-code
        json = JSON.parse(response.body)
        expect(json.length).to eq(0)

    end
 end
 
 
 
context 'when there are ten nearby readings that are too old' do
     it 'returns none of those old, nearby readings' do
        
        StingrayReading.delete_all
        @min = -StingrayReading::NEARBY_RADIUS
        @max = StingrayReading::NEARBY_RADIUS
        #STDERR.puts "nearby dection radius is: " + @radius.to_s
        (1..10).each do |i| 
            test_params['lat'] = test_reading_lat  + rand(@min..@max)
            test_params['long'] = test_reading_long  + rand(@min..@max)
            test_params['observed_at'] = Time.now - 360
            sr  = FactoryGirl.build(:stingray_reading, test_params)
            sr.reverseGeocode
            sr.save
            
            expect(StingrayReading.find(sr.id)).not_to be_nil # ensure it is in database
            #STDERR.puts "#{sr.lat}, #{sr.long}, #{sr.observed_at}"
        end
            
        key = ApiKey.create!
    
        # pass lat, long, time
        nearby_params = {
            lat: test_reading_lat,
            long: test_reading_long,             
            since: Time.now - 240
        }
        get '/nearby.json', {time_and_space: nearby_params}, { :format => :json }
        expect(response).to be_success            # test for the 200 status-code
        json = JSON.parse(response.body)
        expect(json.length).to eq(0)
        #json.each do |sr|
        #    STDERR.puts "nearby: #{sr['unique_token']}: #{sr['latitude']}, #{sr['longitude']}, #{sr['observed_at']}"
        #end
        
    end
    
 end
 
=begin
 context 'when there are ten readings of the same longitude of increasing latitude' do
     it 'verify the longitudal search area increases and handles the polls' do
    
        # pass lat, long, time
        (1..20).each do |i| 
            lat = -89.0 - (i.to_f/20.0)
            long = 45.0
            
            nearby_params = {
                lat: lat,
                long: long,             
                since: Time.now - 120
            }
            get '/nearby.json', {time_and_space: nearby_params}, { :format => :json }
            expect(response).to be_success            # test for the 200 status-code
            json = JSON.parse(response.body)
        end
        #expect(json.length).to eq(10)
        
        #json.each do |sr|
        #    STDERR.puts sr
        #end
        
    end

 end
=end
 
end
