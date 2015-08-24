class StingrayReadingsController < ApplicationController

  # GET /stingray_readings
  # GET /stingray_readings.json
  def index
    threshhold = 15
    if (@bIsAuthorized)
      threshhold = 0
    end

    # cc- temp: buffering req to dp for now
    # note that find_in_batches returns in ASC ascending (not what we want)

    # @stingray_readings = Array.new
    # StingrayReading.where("threat_level >= #{threshhold}").find_in_batches do |readings|
    #   readings.each { |r| @stingray_readings.push r }
    # end

    # ma - I think doing scopes will have a lot of the same benefits of find_in_batches
    # scopes work through ActiveRecord which handles a lot of performance already

    @stingray_readings = StingrayReading.dangerous(threshhold)

    if (@bIsAuthorized)
      render json: @stingray_readings, status: :ok
    else
      render json: @stingray_readings, status: :ok, each_serializer: PublicStingrayReadingSerializer
    end

  end

  # POST /stingray_readings
  # POST /stingray_readings.json
  def create

    unless stingray_reading_params
      render json: {:message => 'invalid json'}, status: :unprocessable_entity
      return
    end

    @stingray_reading = StingrayReading.new(stingray_reading_params)

    if @stingray_reading.save
      render json: @stingray_reading,serializer: UnlocatedStingrayReadingSerializer, status: :created

      # cc: see https://github.com/collectiveidea/delayed_job
      if @stingray_reading.reverseGeocode
        @stingray_reading.save
      end

    else
      render json: @stingray_reading.errors, status: :unprocessable_entity
    end
  end

  private

    def stingray_reading_params
      #cc: don't permit remote setting of flag field
      #cc: don't let user set location, correct? we look that up ourselves..

      #STDERR.puts "got params: " + params.to_json

      unless params.instance_of? ActionController::Parameters
        STDERR.puts "params not a parameter object."
        return nil
      end

      # this catches incorrect json that parses somehow, but uses => instead of :
      stingray_readings = params.require(:stingray_reading)

      unless stingray_readings.instance_of? ActionController::Parameters
         STDERR.puts "stingray readings a string, not a parameter object."
         return nil
      end

      params = stingray_readings.permit(:observed_at, :version, :lat, :long, :threat_level) #, :location)
      return params
    end
end
