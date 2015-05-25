class PagesController < ApplicationController
  def index
  	@imsi_data = ImsiDatum.all
  	@wifi_data = WifiDatum.all
  end
end
