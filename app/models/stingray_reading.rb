class StingrayReading < ActiveRecord::Base
  
  # vzm-todo:cheap, but could use a #define preprocessor when seeding
  # before_create :set_location #turn on while seeding
  module Flags
    SEEDING = 1
    #RESERVED_FLAG_2 = 2
    #RESERVED_FLAG_3 = 4 
    #.. etc
  end
  
  
  # looks up location based on lat/long via Google (free & throttled) geocoding 
  # service.  returns false (indicating do not save) in error conditions when
  # seeding flag is set, so we only seed database with valid entries. 
  #
  # vzm-todo: note on geocode throttling here: this only helps the current thread 
  # throttle its requests, won't help (much) when multiple devices send in 
  # readings. use a queue in a separate process to fill in location values#
  def set_location
    
    l = "Unknown Location"
    require 'net/http'
    
    # vzm: if flag is true, skip if location doesn't exist or not returned:
    @bSeeding = self.flag & Flags::SEEDING > 0 
    
    uri = URI("http://maps.googleapis.com/maps/api/geocode/xml")
    params = { :latlng => [self.lat, self.long].join(","), :sensor => true }
    uri.query = URI.encode_www_form(params)

    @secondsDelay = 1
    @retryCount = 0
    while (true) do
      response = Net::HTTP.get_response(uri)
  
      response_json = Hash.from_xml(response.body) if response.is_a?(Net::HTTPSuccess)
      
      if response_json 
        #puts response_json.map{|k,v| "#{k}=#{v}"}.join(' ')
      
        if response_json["GeocodeResponse"]["result"] 
          results = response_json["GeocodeResponse"]["result"]
          results.each do |result|
            if result.is_a?(Hash) && result.has_key?("type") && result["type"] == "postal_code"
              l = result["formatted_address"]
            end
          end

          STDERR.puts l
          (l == 'Unknown Location' and @bSeeding) ? (return false) : self.location = l
          break
          
        elsif response_json["GeocodeResponse"]["status"] == "OVER_QUERY_LIMIT" 
        
          STDERR.puts "over geocode''s rate limit. rest for #{@secondsDelay} secs (retry ##{@retryCount}/10)" 
          sleep(@secondsDelay)
          # use a capped exponential backoff for timeout:
          @secondsDelay *= 2
          @retryCount = @retryCount + 1
          if @secondsDelay > 128
              @secondsDelay = 128
          end
          if @retryCount >= 10
              break
          end
          next # repeat loop
        elsif response_json["GeocodeResponse"]["status"] == "ZERO_RESULTS" 
          STDERR.puts "no geocode result"
           # don't prepopulate database with lat/longs in the middle of nowhere
          @bSeeding ? (return false) : break 
        end
      else
        STDERR.puts "no response from geocode"
        @bSeeding ? (return false) : break 
      end
    end
    
    return true

  end
    
  private
  
    def googleMapsEndpointFor(latitude, longitude)
      "http://maps.googleapis.com/maps/api/geocode/xml?latlng=" + latitude + "," + longitude + "&sensor=true"
    end
    
    
end
