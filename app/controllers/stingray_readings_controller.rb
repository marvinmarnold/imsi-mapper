class StingrayReadingsController < ApplicationController
  before_action :set_threshold, only: [:index]

  # GET /stingray_readings
  # GET /stingray_readings.json
  def index
    @stingray_readings = StingrayReading.dangerous(@threshold)

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
