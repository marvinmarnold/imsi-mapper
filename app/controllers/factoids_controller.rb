class FactoidsController < ApplicationController
  # GET /factoids
  # GET /factoids.json
  def index
    @factoids = Array.new

    Factoid.find_each do |f|
      @factoids.push f
    end

    render json: @factoids
  end

  private

    def factoid_reading_parmas
      params.require(:factoid).permit(:fact)
    end

end
