module Api
	module V1
	class ImsiDataController < ApplicationController
	  before_action :set_imsi_datum, only: [:show, :edit, :update, :destroy]
	  respond_to :json

	  class ImsiDatum < ::ImsiDatum
	  	def as_json(options={})
	  		super.merge(
	  			"aimsicd_threat_level" =>
	  			ImsiDatum.human_threat_level(aimsicd_threat_level)
	  	)
	  	end
	  end

	  # GET /imsi_data
	  # GET /imsi_data.json
	  def index
	    respond_with ImsiDatum.all#ImsiDatum.where.not(aimsicd_threat_level: "5")
	  end

	  # GET /imsi_data/1
	  # GET /imsi_data/1.json
	  def show
	  	respond_with @imsi_datum
	  end

	  # POST /imsi_data
	  # POST /imsi_data.json
	  def create
	    respond_with ImsiDatum.create imsi_datum_params
	  end

	  # PATCH/PUT /imsi_data/1
	  # PATCH/PUT /imsi_data/1.json
	  def update
	  	respond_with @imsi_datum.update imsi_datum_params
	  end

	  # DELETE /imsi_data/1
	  # DELETE /imsi_data/1.json
	  def destroy
	    respond_with @imsi_datum.destroy
	  end

	  private
	    # Use callbacks to share common setup or constraints between actions.
	    def set_imsi_datum
	      @imsi_datum = ImsiDatum.find(params[:id])
	    end

	    # Never trust parameters from the scary internet, only allow the white list through.
	    def imsi_datum_params
	      params.require(:imsi_datum).permit(
	      	:aimsicd_threat_level,
	      	:latitude_degrees,
	      	:longitude_degrees,
	      	:observed_at
	   		)
	    end
	end
	end
end