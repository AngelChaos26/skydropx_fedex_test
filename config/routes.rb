Rails.application.routes.draw do
  resources :packages, only: %i[index]
  # Rails ActionCable server
  mount ActionCable.server => '/cable'
end
