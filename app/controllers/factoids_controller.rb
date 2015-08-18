class FactoidsController < ApplicationController
    
    
  before_action :set_factoid, only: [:show, :update, :destroy]
    
    
  # GET /factoids
  # GET /factoids.json
  def index

    factoids = Array.new
    
    Factoid.find_each do |f|
      factoids.push f
    end
    
    render json: factoids
    
  end

    
  # POST /factoids
  # POST /factoids.json
  
  ## cc-todo: protect this with @bIsAuthorized
  def create
    @factoid = Factoid.new(factoid_reading_parmas)

    if @factoid.save
      render json: @factoid, status: :created, location: @factoid
    else
      render json: @factoid.errors, status: :unprocessable_entity
    end
    
  end
  
  
  # GET /factoids/1
  # GET /factoids/1.json
  def show
  
    render json: @factoid
  end
  
  private
  
    def factoid_reading_parmas
      params.require(:factoid).permit(:fact)
    end
  
    def set_factoid
      
      @factoid = Factoid.find(params[:id])
      
    end
    
end
