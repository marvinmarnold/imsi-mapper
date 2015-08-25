require 'net/http'

class StingrayReading < ActiveRecord::Base
  before_save :ensure_reverse_geocode
  before_save :normalize_observed_at

  NEARBY_RADIUS = 0.0005
  DEGREES_TO_RADIANS = Math::PI / 180

  scope :dangerous, ->(threat_tolerance) { where("threat_level >= ?", threat_tolerance).order(observed_at: :desc)}

  scope :nearby,
    ->(threathold, lat, long, since) { # threathold = threshold of the threat, you thee
      #cc-todo: should validate range of lat, long and time beforehand
      minlat = lat.to_f - NEARBY_RADIUS
      maxlat = lat.to_f + NEARBY_RADIUS

      if (lat.to_f < 89.9999 and lat.to_f > -89.9999)
        longitudeCorrection = NEARBY_RADIUS/Math.cos(lat.to_f * DEGREES_TO_RADIANS)
        #STDERR.puts "adjusting degrees of longitudinal search area from #{NEARBY_RADIUS} to #{longitudeCorrection} for latitude: #{lat}"
        minlong = long.to_f - longitudeCorrection
        maxlong = long.to_f + longitudeCorrection
        return where("threat_level >= ? and lat >= ? and lat <= ? and long >= ? and long <= ? and observed_at > ?", threathold, minlat, maxlat, minlong, maxlong, since).order(observed_at: :desc)
      else
        # we're very near the north or south pole. disregard searching by longitude
        #STDERR.puts "we're very near the north or south poll: #{lat}. disregard restricting search by longitude"
        return where("threat_level >= ? and lat >= ? and lat <= ? and observed_at > ?", threathold, minlat, maxlat, since).order(observed_at: :desc)
      end

    }

  # round off all lat longs to four decimals before storing them:
  before_update :beforeUpdateOrCreate
  before_create :beforeUpdateOrCreate
  after_initialize :after_initialize
  has_secure_token :unique_token

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
      beforeUpdateOrCreate
  end

  # calls configured reverse geocode API: mapbox or google
  # this sets our location field to a placename string corresponding to
  # our lat & long. assumes lat & long already set.
  def reverse_geocode
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
    @sGoogleGeocodeURL= "http://localhost/mock" # for testing timeout logic
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


  # over ride lat /long setters so we update our lower res lat/longs
  def self.lat=(val)
    self.lat =val
    setLowerResLatLongs
  end

  def self.long=(val)
    self.lat =val
    setLowerResLatLongs
  end


  private

    # ma: as noted elsewhere, this should not block
    def ensure_reverse_geocode
      reverse_geocode unless location
    end

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

      # STDERR.puts "first feature: " + firstFeature.inspect + "\n\n"

      if firstFeature.try(:[],'id') =~ /^address\.\d+$/ && firstFeature.try(:[],'type') == 'Feature'

        secondFeature = features.try(:[],1)
        return false unless secondFeature

       # STDERR.puts "second feature: " + secondFeature.inspect + "\n\n"


        contexts = firstFeature.try(:[],'context')
        contexts.each do |c|
          self.region = c.try(:[],'text') if c.try(:[],'id') =~ /^region\.[\d]+$/
        end
        #STDERR.puts "got region of #{self.region}" if self.region
        #STDERR.puts "got no region " + contexts.inspect unless self.region

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

    def beforeUpdateOrCreate()
      setLowerResLatLongs
    end

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

    def normalize_observed_at
      self.observed_at = self.observed_at.to_datetime
    end
end
