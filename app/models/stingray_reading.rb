class StingrayReading < ActiveRecord::Base
  
  # before_create :set_location #turn on while seeding
  

  module Flags
    SEEDING = 0
    PREPOPULATED = 1
    RESERVED_FLAG_3 = 2
    RESERVED_FLAG_4 = 4 
    #.. 8, etc
  end

  # set seeding to true or false
  def seeding=(bVal)
    # clear previous value for flag:
    self.flag &= 0b11111110
    # OR the cleared flag with new value to set it:
    self.flag |= ( bVal ? 1 : 0  )
  end
  
  def seeding
    return (self.flag & 0b0000_0001) > 0
  end    
  
  # set prepopulated to true or false
  # vzm: separate flag for this because we clear the seeding flag before saving
  # it, as we don't want to use "seeding" logic for handling geocoding errors
  # if we ever UPDATE/PUT the seeding entries. (admittedly, unlikely, but possible).
  # yet we may still want to track which values were initially prepopulated.
  def prepopulated=(bVal)
    # clear previous value for flag
    self.flag &= 0b11111101
    # OR the cleared flag with new value to set it:
    self.flag |= (( bVal ? 1 : 0  ) << Flags::PREPOPULATED)
  end
  
  def prepopulated
    return (self.flag & 0b0000_0010) > 0 
  end
  
  # looks up location based on lat/long via Google (free & throttled) geocoding 
  # service.  returns false (indicating do not save) in error conditions when
  # SEEDING flag is true, so that we only seed db wiht entries that have locations 
  # values
  #
  # vzm-todo: note on geocode throttling herein: this only helps the current thread 
  # throttle its requests and won't help (much) when multiple devices send in 
  # readings. could use a queue in a separate process to populate location values.
  def set_location
    
    l = "Unknown Location"
    require 'net/http'
    
    uri = URI("http://maps.googleapis.com/maps/api/geocode/xml")
    params = { :latlng => [self.lat, self.long].join(","), :sensor => true }
    uri.query = URI.encode_www_form(params)

    @secondsDelay = 1
    @retryCount = 0
    while (true) do
      response = Net::HTTP.get_response(uri)
  
      response_json = Hash.from_xml(response.body) if response.is_a?(Net::HTTPSuccess)
      
      if response_json 
        #puts response_json.map{|k,v| "#{k}=#{v}"}.join(' ') # for debugging
      
        if response_json["GeocodeResponse"]["result"] 
          results = response_json["GeocodeResponse"]["result"]
          results.each do |result|
            if result.is_a?(Hash) && result.has_key?("type") && result["type"] == "postal_code"
              l = result["formatted_address"]
            end
          end

          STDERR.puts l
          (l == 'Unknown Location' and self.seeding) ? (return false) : self.location = l
          break
          
        elsif response_json["GeocodeResponse"]["status"] == "OVER_QUERY_LIMIT" 
        
          STDERR.puts "over geocode''s rate limit. rest for #{@secondsDelay} secs (retry ##{@retryCount}/10)" 
          sleep(@secondsDelay)
          # use a capped exponential backoff for timeout:
          @secondsDelay *= 2
          @retryCount = @retryCount + 1
          @secondsDelay = 128 if @secondsDelay > 128
          break if @retryCount >= 10
          next # repeat loop
        elsif response_json["GeocodeResponse"]["status"] == "ZERO_RESULTS" 
          STDERR.puts "no geocode result"
           # don't prepopulate database with lat/longs in the middle of nowhere
          self.seeding ? (return false) : break 
        end
      else
        STDERR.puts "no response from geocode"
        self.seeding ? (return false) : break 
      end
    end
    
    return true

  end
    
  private
  
    # vzm: appears unused
    def googleMapsEndpointFor(latitude, longitude)
      "http://maps.googleapis.com/maps/api/geocode/xml?latlng=" + latitude + "," + longitude + "&sensor=true"
    end
    
    
end
