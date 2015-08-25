class NearbyController < ApplicationController

  before_action :set_threshold

  # GET /nearby
  # GET /nearby.json
  # Takes {time_and_space: {lat: LAT, long: LONG, since: SINCE}} and returns
  # an array of StingrayReadings. If request sent without a valid token,
  # only the fields unique_token and observed_at are returned.
  def index

    unless time_space_params
      render json: {:message => 'Invalid JSON. Requires {time_and_space: {lat: LAT, long: LONG, since: SINCE}}'}, status: :unprocessable_entity
      return
    end

    tsp = time_space_params
    nearby_readings = StingrayReading.nearby(@threshold, tsp[:lat], tsp[:long], tsp[:since])

    if (@bIsAuthorized)
      render json: nearby_readings, status: :ok
    else
      render json: nearby_readings, status: :ok, each_serializer: PublicNearbyReadingSerializer
    end

  end

  private

    def time_space_params

      #STDERR.puts "got params: " + params.to_json

      unless params.instance_of? ActionController::Parameters
        STDERR.puts "params not a parameter object."
        return nil
      end

      # this catches incorrect json that parses somehow, but uses => instead of :
      time_and_space = params.require(:time_and_space)

      unless time_and_space.instance_of? ActionController::Parameters
         STDERR.puts "time_and_space not a valid parameter"
         return nil
      end

      #STDERR.puts "got time and space: " + time_and_space.to_json

      params = time_and_space.permit(:lat,:long,:since) #, :location)

      return params
    end

end
