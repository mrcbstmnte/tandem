Rails.application.routes.draw do
  resources :boards do
    resources :cards, only: %i[ create edit update destroy ] do
      patch :move, on: :member
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "boards#index"
end
