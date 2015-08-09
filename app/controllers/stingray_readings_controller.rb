class StingrayReadingsController < ApplicationController
  
  before_action :set_stingray_reading, only: [:show, :update, :destroy]

  @bAuthorized = false #placeholder
  
  # GET /stingray_readings
  # GET /stingray_readings.json
  def index

    # vzm-todo: added token checking logic later before rounding
    
    # vzm: @marvin, not sure how integers correspond to red and skull levels,
    # so change next line as needed:
    @stingray_readings = StingrayReading.where("threat_level > 3")
    
    if (!@bIsAuthorized)
      @stingray_readings.each do |reading|
          roundLatLong(reading)
      end
    end
    render json: @stingray_readings
  end

  # GET /stingray_readings/1
  # GET /stingray_readings/1.json
  def show
    
    render json: @stingray_reading
  end

  # POST /stingray_readings
  # POST /stingray_readings.json
  def create
    @stingray_reading = StingrayReading.new(stingray_reading_params)

    if @stingray_reading.save
      render json: @stingray_reading, status: :created, location: @stingray_reading
      
      # vzm: see https://github.com/collectiveidea/delayed_job
      if @stingray_reading.set_location() 
        @stingray_reading.save()
      end
    
    else
      render json: @stingray_reading.errors, status: :unprocessable_entity
    end
    
  end

  # PATCH/PUT /stingray_readings/1
  # PATCH/PUT /stingray_readings/1.json
  def update
    @stingray_reading = StingrayReading.find(params[:id])

    if @stingray_reading.update(stingray_reading_params)
      head :no_content
      
      #vzm-todo: only update if lat/long changed 
      #vzm-todo:this logic could be in the model, like in a "before_update"
      if @stingray_reading.set_location() 
        @stingray_reading.save()
      end

    else
      render json: @stingray_reading.errors, status: :unprocessable_entity
    end
  end

  # DELETE /stingray_readings/1
  # DELETE /stingray_readings/1.json
  def destroy
    @stingray_reading.destroy

    head :no_content
  end

  private

    def set_stingray_reading
      @stingray_reading = StingrayReading.find(params[:id])
      
      if (!@bIsAuthorized) 
        roundLatLong(@stingray_reading)
      end

    end

    # round the lat/long of the given reading to 3 decimal places
    def roundLatLong(reading)
      # vzm-todo: might want to store rounded values:
      reading.lat = (reading.lat * 1000).floor / 1000.0
      reading.long = (reading.long * 1000).floor / 1000.0
    end

    def stingray_reading_params
      #vzm: don't permit remote setting of flag field
      #vzm: don't let user set location, correct? we look that up ourselves..
      params.require(:stingray_reading).permit(:observed_at, :version, :lat, :long, :threat_level) #, :location)
    end
end
