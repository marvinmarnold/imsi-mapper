module Api
  module V1
    class WifiDataController < ApplicationController
      before_action :set_wifi_datum, only: [:show, :edit, :update, :destroy]

      # GET /wifi_data
      # GET /wifi_data.json
      def index
        respond_with WifiDatum.all
      end

      # GET /wifi_data/1
      # GET /wifi_data/1.json
      def show
        respond_with @wifi_datum
      end

      # POST /wifi_data
      # POST /wifi_data.json
      def create
        respond_with WifiDatum.create(wifi_datum_params)
      end

      # PATCH/PUT /wifi_data/1
      # PATCH/PUT /wifi_data/1.json
      def update
        respond_with @wifi_datum.update(wifi_datum_params)
      end

      # DELETE /wifi_data/1
      # DELETE /wifi_data/1.json
      def destroy
        respond_with @wifi_datum.destroy
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_wifi_datum
          @wifi_datum = WifiDatum.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def wifi_datum_params
          params.require(:wifi_datum).permit(
            :num_wifi_hotspots,
            :latitude_degrees,
            :longitude_degrees,
            :observed_at)
        end
    end
  end
end