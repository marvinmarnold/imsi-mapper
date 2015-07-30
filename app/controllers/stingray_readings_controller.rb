class StingrayReadingsController < ApplicationController
  before_action :set_stingray_reading, only: [:show, :update, :destroy]

  # GET /stingray_readings
  # GET /stingray_readings.json
  def index
    @stingray_readings = StingrayReading.all

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
    end

    def stingray_reading_params
      params.require(:stingray_reading).permit(:observed_at, :version, :lat, :long, :threat_level)
    end
end
