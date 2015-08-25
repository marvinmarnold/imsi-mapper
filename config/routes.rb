Rails.application.routes.draw do
  post '/stingray_readings', to: 'stingray_readings#create', as: 'create_stingray_reading'
  get '/stingray_readings', to: 'stingray_readings#index'
  get '/factoids', to: 'factoids#index', as: 'factoids'
  get '/nearby', to: 'nearby#index', as: 'nearby'
end
