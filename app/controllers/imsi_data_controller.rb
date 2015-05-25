class ImsiDataController < ApplicationController
  before_action :set_imsi_datum, only: [:show, :edit, :update, :destroy]

  # GET /imsi_data
  # GET /imsi_data.json
  def index
    @imsi_data = ImsiDatum.all
  end

  # GET /imsi_data/1
  # GET /imsi_data/1.json
  def show
  end

  # GET /imsi_data/new
  def new
    @imsi_datum = ImsiDatum.new
  end

  # GET /imsi_data/1/edit
  def edit
  end

  # POST /imsi_data
  # POST /imsi_data.json
  def create
    @imsi_datum = ImsiDatum.new(imsi_datum_params)

    respond_to do |format|
      if @imsi_datum.save
        format.html { redirect_to @imsi_datum, notice: 'Imsi datum was successfully created.' }
        format.json { render :show, status: :created, location: @imsi_datum }
      else
        format.html { render :new }
        format.json { render json: @imsi_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /imsi_data/1
  # PATCH/PUT /imsi_data/1.json
  def update
    respond_to do |format|
      if @imsi_datum.update(imsi_datum_params)
        format.html { redirect_to @imsi_datum, notice: 'Imsi datum was successfully updated.' }
        format.json { render :show, status: :ok, location: @imsi_datum }
      else
        format.html { render :edit }
        format.json { render json: @imsi_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /imsi_data/1
  # DELETE /imsi_data/1.json
  def destroy
    @imsi_datum.destroy
    respond_to do |format|
      format.html { redirect_to imsi_data_url, notice: 'Imsi datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_imsi_datum
      @imsi_datum = ImsiDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def imsi_datum_params
      params.require(:imsi_datum).permit(:aimsicd_threat_level)
    end
end
