require 'net/http'

class StingrayReading < ActiveRecord::Base
  
  before_create :roundLatLongToFourDecimals
 

  # class instance vars for setting lengths of naps )(for querying overloaded
  # geocode API):
  MAX_NUMBER_OF_NAPS = 5
  LONGEST_NAP_IN_SECONDS = 8
  GEOCODER = :mapbox # :google
  
  module Flags
    SEEDING = 0 # we don't need to save this value, really
    PREPOPULATED = 1
    RESERVED_FLAG_3 = 2
    RESERVED_FLAG_4 = 4 
    #.. 8, etc
  end
  
  def reverseGeocode
    if GEOCODER == :mapbox
        reverseGeocodeViaMapBox
    elsif GEOCODER == :google
        reverseGeocodeViaGoogle
    end
    
  end
  
  
  
  def geocodeurl=(url)
    @sGoogleGeocodeURL = url
  end
  
  
  # set seeding to true or false
  def seeding=(bVal)
    # clear previous value for flag:
    self.flag &= 0b11111110
    # OR the cleared flag with new value to set it:
    self.flag |= ( bVal ? 1 : 0  )
  end
  
  # returns true if seeding flag set, false if not
  def seeding
    return (self.flag & 0b0000_0001) > 0
  end    
  
  # set prepopulated to true or false
  # cc: separate flag for this because we clear the seeding flag before saving
  # it, as we don't want to use "seeding" logic for handling geocoding errors
  # if we ever UPDATE/PUT the seeded entries. (admittedly, unlikely, but possible)
  # yet we may still want to track which values were initially prepopulated.
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
  
  
  def reverseGeocodeViaMapBox
    
    # mapbox url format = "https://api.mapbox.com/v4/geocode/{dataset}/{lon},{lat}.json?access_token=<your access token>";

    # mapbox access token
    sMapboxAccessToken = "pk.eyJ1IjoibWFjd2FuZyIsImEiOiI2N2FhMGUzZWQzZjhlMTU3YzM4ZTBiZmQ5ZDViMGMxNCJ9.2sV6xIsWgQ7UAv4Df0w0ZA"
    
    # mapbox url:
    sMapBoxBaseURL = "https://api.mapbox.com/v4/geocode/";
  
    latlng = [self.long, self.lat].join(",")
    
    sUrl = "#{sMapBoxBaseURL}mapbox.places/#{latlng}.json?access_token=#{sMapboxAccessToken}"
    
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
  # service.  returns false (indicating do not save) in error conditions when
  # SEEDING flag is true, so that we only seed db wiht entries that have locations 
  # values
  #
  # cc-todo: note on geocode throttling herein: this only helps the current thread 
  # throttle its requests and won't help (much) when multiple devices send in 
  # readings. could use a queue in a separate process to populate location values.
  def reverseGeocodeViaGoogle
    
    l = "Unknown Location"

    sGoogleGeocodeURL = "https://maps.googleapis.com/maps/api/geocode/xml"

    uri = URI(sGoogleGeocodeURL)
    params = { :latlng => [self.lat, self.long].join(","), :sensor => true }
    uri.query = URI.encode_www_form(params)

    considerNapping()
    while (true) do
      response = Net::HTTP.get_response(uri)
  
      response_json = Hash.from_xml(response.body) if response.is_a?(Net::HTTPSuccess)
      
      if response_json 
        
        if response_json["GeocodeResponse"]["result"] 
          results = response_json["GeocodeResponse"]["result"]
          results.each do |result|
            if result.is_a?(Hash) && result.has_key?("type") && result["type"] == "postal_code"
              l = result["formatted_address"]
            end
          end

          #STDERR.puts "google location: #{l}"
          (l == 'Unknown Location' and self.seeding) ? (return false) : self.location = l
          break
          
        elsif response_json["GeocodeResponse"]["status"] == "OVER_QUERY_LIMIT" 
        
          next if napAndTryAgain?()  
          self.seeding ? (return false) : break 
          
        elsif response_json["GeocodeResponse"]["status"] == "ZERO_RESULTS" 
          #STDERR.puts "no geocode result"
           # marvin: shall we not seed db with lat/longs in middle of nowhere?
          self.seeding ? (return false) : break 
        end
      else
        # cc: haven't seen this code path taken. (likely only on network error?)
        #STDERR.puts "no response from geocode. network error?"
        return false if self.seeding
        # if not seeding, sleep and try again a few times:
        napAndTryAgain?() ? next : break 
      end
    end
    
    return true

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
