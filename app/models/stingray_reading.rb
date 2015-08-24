require 'net/http'

class StingrayReading < ActiveRecord::Base

  scope :dangerous, ->(threat_tolerance) { where("threat_level >= ?", threat_tolerance).order(observed_at: :desc)}

  # round off all lat longs to four decimals before storing them:
  before_update :setLowerResLatLongs
  before_create :setLowerResLatLongs
  after_initialize :after_initialize

  # class variable used to choose which resoluton of lat / long to display
  # see as_json
  @@resolution = "low"

  # class instance vars for setting number and lengths of naps (when querying overloaded
  # google geocode API):
  MAX_NUMBER_OF_NAPS = 5
  LONGEST_NAP_IN_SECONDS = 8

  # bit flags for our flag field
  module Flags
    RESERVED_FLAG = 0
    PREPOPULATED = 1
    RESERVED_FLAG_3 = 2
    RESERVED_FLAG_4 = 4
    #.. 8, etc
  end

  # initialize our instance vars
  def after_initialize
      @symGeocoder = :mapbox # :google
      @sMapboxAccessToken = "pk.eyJ1IjoibWFjd2FuZyIsImEiOiI2N2FhMGUzZWQzZjhlMTU3YzM4ZTBiZmQ5ZDViMGMxNCJ9.2sV6xIsWgQ7UAv4Df0w0ZA"
      @sMapBoxBaseURL = "https://api.mapbox.com/v4/geocode/";
      @sGoogleGeocodeURL = "https://maps.googleapis.com/maps/api/geocode/xml"

      # in case user calls "build", update_create doesn't get called.
      setLowerResLatLongs
  end

  # calls configured reverse geocode API: mapbox or google
  # this sets our location field to a placename string corresponding to
  # our lat & long. assumes lat & long already set.
  def reverseGeocode
    if @symGeocoder == :mapbox
        return reverseGeocodeViaMapBox
    elsif @symGeocoder == :google
        return reverseGeocodeViaGoogle
    end

    STDERR.puts "no geocoder set: #{@symGeocoder}"
    return false

  end

  def useMapboxGeocoder
    @symGeocoder = :mapbox
  end

  def useGoogleGeocoder
    @symGeocoder = :google
    @sGoogleGeocodeURL = "https://maps.googleapis.com/maps/api/geocode/xml"
  end

  # to test our time out handling with rspec
  def useFakeTimeoutGoogleGeocoder
    @symGeocoder = :google
    @sGoogleGeocodeURL= "https://stinger-api-vannm.c9.io/mock" # for testing timeout logic
  end

  ##
  # GETTERS/SETTERS
  #

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

  def self.resolution=(val)
    @@resolution = val
  end

  def self.resolution
    @@resolution
  end

  # over ride lat /long setters so we update our lower res lat/longs
  def self.lat=(val)
    self.lat =val
    setLowerResLatLongs
  end

  def self.long=(val)
    self.lat =val
    setLowerResLatLongs
  end


    # called by to_json. we use it to limit the lat / long resolution displayed
    # depending on the setting of the @@resolution class variable
    # cc: having to enumerate all the fields is rather fragile
    def as_json options={}

      attrs = {
                "id" => self.id,
                "observed_at" => self.observed_at,
                "version" => self.version,
                "threat_level" => self.threat_level,
                "created_at" => self.created_at,
                "updated_at" => self.updated_at,
                "location" => self.location
      }

      if @@resolution == 'low'
        attrs['lat'] = self.low_res_lat
        attrs['long'] = self.low_res_long
      end
      if @@resolution == 'medium'
        attrs['lat'] = self.med_res_lat
        attrs['long'] = self.med_res_long
      end
      if @@resolution == 'high'
        attrs['lat'] = self.high_res_lat
        attrs['long'] = self.high_res_long
      end

      return attrs

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

      features = j.try(:[],"features")
      firstFeature = features.try(:[],0) #.try(:[],"text")
      return false unless firstFeature

      if firstFeature.try(:[],'id') =~ /^address\.\d+$/ && firstFeature.try(:[],'type') == 'Feature'

        secondFeature = features.try(:[],1)
        return false unless secondFeature

        if secondFeature.try(:[],'id') =~ /^place\.\d+$/

          # we got an exact street address match for the lat & long.
          #   "text" value is street name only
          #   "address" the street number only
          #   "place_name" the complete address

          # second feature place_name contains city, state etc, everything but street name

          address = firstFeature.try(:[],'address')
          if (!address)
              # STDERR.puts " no street ddress? " + firstFeature.inspect
              sObscurredStreetNumber = ''
          else
              sObscurredStreetNumber = 'The ' + obscureStreetNumber(address)  + ' block of '
          end

          sStreetName = firstFeature.try(:[],'text')
          sPlace = secondFeature.try(:[],'place_name')

          self.location = sObscurredStreetNumber + sStreetName + ', ' + sPlace
          #STDERR.puts self.location
        end

      else
          # if first result isn't of that type, return the whole place_name value?
          self.location = firstFeature.try(:[],'place_name')
          #STDERR.puts 'got inexact address: ' + self.location
      end

      return self.location

    end

    # takes a streetnumber, which may start with a letter, and returns it rounded
    # to the nearest hundreds. this could use some tightening:
    def obscureStreetNumber(sn)

      return '' unless sn

      unless (md = /^([a-zA-Z]*)(\d+)$/.match(sn.to_s))
        STDERR.puts "no match to format of our street number regex? sn: #{sn}"
        return ''
      end
      captured = md.captures
      # we sometimes get addresses like N2342. break off the leading letters:
      sStreetAddressLetterPrefix = captured[0]
      digitsOnly = captured[1]

      numDigits = digitsOnly.length
      # any number from 0-100 return as "100" (b/c "0 block of x" sounds weird):
      return sStreetAddressLetterPrefix + "100" if (numDigits <= 2)

      # round off to nearest hundreds, which typically is a block?
      unless (md = /^(\d+)(\d{2,2})/.match(digitsOnly))
        STDERR.puts "could not round off digits: '#{digitsOnly}'"
        return ''
      end
      captured = md.captures
      obscuredDigits = captured[0] + '00'

      # return rounded off street address
      return sStreetAddressLetterPrefix + obscuredDigits

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
          if response_json["GeocodeResponse"]["result"]
            results = response_json["GeocodeResponse"]["result"]
            results.each do |result|
              if result.is_a?(Hash) && result.has_key?("type") && result["type"] == "postal_code"
                l = result["formatted_address"]
              end
            end
            self.location = l
            return true
          elsif response_json["GeocodeResponse"]["status"] == "OVER_QUERY_LIMIT"
            next if napAndTryAgain?()
            return false
          elsif response_json["GeocodeResponse"]["status"] == "ZERO_RESULTS"
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

      return false
    end

    ##
    # sleep code
    #

    # initialize our variables to track how long and how many times to nap
    def considerNapping()
      @iSecondsToNap = 2
      @iNumberOfNaps = 1
    end

    # nap, and return true if should continue trying
    def napAndTryAgain?()
      STDERR.puts "throttle. resting for #{@iSecondsToNap} secs (retry ##{@iNumberOfNaps}/#{MAX_NUMBER_OF_NAPS})"
      sleep(@iSecondsToNap)
      # use a capped exponential backoff for timeout:
      @iSecondsToNap *= 2
      @iNumberOfNaps += 1
      @iSecondsToNap = LONGEST_NAP_IN_SECONDS if @iSecondsToNap > LONGEST_NAP_IN_SECONDS
      @iNumberOfNaps > MAX_NUMBER_OF_NAPS ?  false : true
    end

    ##
    # utils
    #

    # round the lat/long to 5 and 3 decimal places
    def setLowerResLatLongs()
      self.med_res_lat = (self.lat * 100000).floor / 100000.0
      self.med_res_long = (self.long * 100000).floor / 100000.0
      self.low_res_lat = (self.lat * 1000).floor / 1000.0
      self.low_res_long = (self.long * 1000).floor / 1000.0
    end



    # cc: appears unused
    def googleMapsEndpointFor(latitude, longitude)
      "http://maps.googleapis.com/maps/api/geocode/xml?latlng=" + latitude + "," + longitude + "&sensor=true"
    end

end
