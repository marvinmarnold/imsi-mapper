Rails.application.routes.draw do
  resources :stingray_readings, only: [:create, :index], defaults: {format: 'json'}
  resources :factoids, only: [:index], defaults: {format: 'json'}
  resources :mock, only: [:create]
  resources :nearby, only: [:index]
end
