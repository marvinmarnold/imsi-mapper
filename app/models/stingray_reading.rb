require 'net/http'

class StingrayReading < ActiveRecord::Base
  
  before_create :roundLatLongToFourDecimals
 
  # class instance vars for setting lengths of naps )(for querying overloaded
  # geocode API):
  MAX_NUMBER_OF_NAPS = 5
  LONGEST_NAP_IN_SECONDS = 8
  
  module Flags
    RESERVED_FLAG = 0
    PREPOPULATED = 1
    RESERVED_FLAG_3 = 2
    RESERVED_FLAG_4 = 4 
    #.. 8, etc
  end
  
  def after_initialize
      @symGeocoder = :mapbox # :google
      @sMapboxAccessToken = "pk.eyJ1IjoibWFjd2FuZyIsImEiOiI2N2FhMGUzZWQzZjhlMTU3YzM4ZTBiZmQ5ZDViMGMxNCJ9.2sV6xIsWgQ7UAv4Df0w0ZA"
      @sMapBoxBaseURL = "https://api.mapbox.com/v4/geocode/";
      @sGoogleGeocodeURL = "https://maps.googleapis.com/maps/api/geocode/xml"
  end
  
  
  def reverseGeocode
    if @symGeocoder == :mapbox
        reverseGeocodeViaMapBox
    elsif @symGeocoder == :google
        reverseGeocodeViaGoogle
    end
    
  end
  
  
  def useGoogleGeocoder
    @symGeocoder = :google
  end  

  # to test time out with rspec
  def useFakeTimeoutGoogleGeocoder
    @symGeocoder = :google
    @sGoogleGeocodeURL= "https://stinger-api-vannm.c9.io/mock" # for testing timeout logic
  end  
  
  def useMapboxGeocoder
    @symGeocoder = :mapbox
  end  

  
  # set prepopulated to true or false
  # track which values were initially prepopulated.
  def prepopulated=(bVal)
    # clear previous value for flag
    self.flag &= 0b11111101
    # OR the cleared flag with new value to set it:
    self.flag |= (( bVal ? 1 : 0  ) << Flags::PREPOPULATED)
  end
  
  # returns true if prepoluated flag set, false if not
  def prepopulated
    return (self.flag & 0b0000_0010) > 0 
  end    

  private
  
  
    # query mapbox with lat long and fill in location value of reading with result
    # return false if no result, true otherwise
    def reverseGeocodeViaMapBox
      
      # mapbox url format = "https://api.mapbox.com/v4/geocode/{dataset}/{lon},{lat}.json?access_token=<your access token>";
  
      longlat = [self.long, self.lat].join(",")
      
      sUrl = "#{@sMapBoxBaseURL}mapbox.places/#{longlat}.json?access_token=#{@sMapboxAccessToken}"
      
      #STDERR.puts "mapbox url: #{sUrl}"
  
      uri = URI(sUrl)
      response = Net::HTTP.get_response(uri)
      j = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
      
      return false unless j
      return false unless j["features"]
      return false unless j["features"][0] 
      return false unless j["features"][0]["place_name"]
      
      self.location = j["features"][0]["place_name"]
      return true
  
    end
    
    
    # looks up location based on lat/long via Google (free & throttled) geocoding 
    # service. returns true if it responds with known location, false otherwise
    #
    # cc-todo: note on geocode throttling herein: this only helps the current thread 
    # throttle its requests and won't help (much) when multiple devices send in 
    # readings. could use a queue in a separate process to populate location values.
    def reverseGeocodeViaGoogle
      
      l = "Unknown Location"
  
      uri = URI(@sGoogleGeocodeURL)
      params = { :latlng => [self.lat, self.long].join(","), :sensor => true }
      uri.query = URI.encode_www_form(params)
  
      considerNapping()
      while (true) do
        response = Net::HTTP.get_response(uri)
    
        response_json = Hash.from_xml(response.body) if response.is_a?(Net::HTTPSuccess)
        
        if response_json 
          if response_json["@symGeocoderesponse"]["result"] 
            results = response_json["@symGeocoderesponse"]["result"]
            results.each do |result|
              if result.is_a?(Hash) && result.has_key?("type") && result["type"] == "postal_code"
                l = result["formatted_address"]
              end
            end
            self.location = l
            return true
          elsif response_json["@symGeocoderesponse"]["status"] == "OVER_QUERY_LIMIT" 
            next if napAndTryAgain?()  
            return false 
          elsif response_json["@symGeocoderesponse"]["status"] == "ZERO_RESULTS" 
            #STDERR.puts "no geocode result"
            return false
          end
        else
          # cc: haven't seen this code path taken. (likely only on network error?)
          STDERR.puts "no response from geocode. network error?"
          # sleep and try again a few times:
          napAndTryAgain?() ? next : (return false) 
        end
      end
      
  
    end
    
    # initialize our variables to track how long and how many times to nap
    def considerNapping()
      @iSecondsToNap = 2
      @iNumberOfNaps = 1
    end
  
    # nap, and return true if should continue trying
    def napAndTryAgain?()
      STDERR.puts "geocode throttling us. resting for #{@iSecondsToNap} secs (retry ##{@iNumberOfNaps}/#{MAX_NUMBER_OF_NAPS})" 
      sleep(@iSecondsToNap)
      # use a capped exponential backoff for timeout:
      @iSecondsToNap *= 2
      @iNumberOfNaps += 1
      @iSecondsToNap = LONGEST_NAP_IN_SECONDS if @iSecondsToNap > LONGEST_NAP_IN_SECONDS
      @iNumberOfNaps > MAX_NUMBER_OF_NAPS ?  false : true
    end
  
    # cc: appears unused
    def googleMapsEndpointFor(latitude, longitude)
      "http://maps.googleapis.com/maps/api/geocode/xml?latlng=" + latitude + "," + longitude + "&sensor=true"
    end
    
     # round the lat/long of the given reading to 4 decimal places
    def roundLatLongToFourDecimals()
      self.lat = (self.lat * 10000).floor / 10000.0
      self.long = (self.long * 10000).floor / 10000.0
    end
    
end
