class NearbyController < ApplicationController
    
  # GET /nearby
  # GET /nearby.json
  def index
      
    unless time_space_params
      render json: {:message => 'invalid json'}, status: :unprocessable_entity
      return
    end

    threshhold = 15
    if (@bIsAuthorized)
      threshhold = 0
    end

    tsp = time_space_params
    nearby_readings = StingrayReading.nearby(threshhold,tsp[:lat],tsp[:long],tsp[:since])

    if (@bIsAuthorized)
      render json: nearby_readings, status: :ok
    else
      render json: nearby_readings, status: :ok, each_serializer: PublicStingrayReadingSerializer
    end

  end
  
  private
  
    def time_space_params


      STDERR.puts "got params: " + params.to_json


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
