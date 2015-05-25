class WifiDataController < ApplicationController
  before_action :set_wifi_datum, only: [:show, :edit, :update, :destroy]

  # GET /wifi_data
  # GET /wifi_data.json
  def index
    @wifi_data = WifiDatum.all
  end

  # GET /wifi_data/1
  # GET /wifi_data/1.json
  def show
  end

  # GET /wifi_data/new
  def new
    @wifi_datum = WifiDatum.new
  end

  # GET /wifi_data/1/edit
  def edit
  end

  # POST /wifi_data
  # POST /wifi_data.json
  def create
    @wifi_datum = WifiDatum.new(wifi_datum_params)

    respond_to do |format|
      if @wifi_datum.save
        format.html { redirect_to @wifi_datum, notice: 'Wifi datum was successfully created.' }
        format.json { render :show, status: :created, location: @wifi_datum }
      else
        format.html { render :new }
        format.json { render json: @wifi_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wifi_data/1
  # PATCH/PUT /wifi_data/1.json
  def update
    respond_to do |format|
      if @wifi_datum.update(wifi_datum_params)
        format.html { redirect_to @wifi_datum, notice: 'Wifi datum was successfully updated.' }
        format.json { render :show, status: :ok, location: @wifi_datum }
      else
        format.html { render :edit }
        format.json { render json: @wifi_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wifi_data/1
  # DELETE /wifi_data/1.json
  def destroy
    @wifi_datum.destroy
    respond_to do |format|
      format.html { redirect_to wifi_data_url, notice: 'Wifi datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wifi_datum
      @wifi_datum = WifiDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wifi_datum_params
      params.require(:wifi_datum).permit(:num_wifi_hotspots, :latitude_degrees, :longitude_degrees)
    end
end
