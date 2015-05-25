class PagesController < ApplicationController
  def index
  	@num_data = ImsiDatum.all.size
  end
end
