Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "home#index"
  resources :hands, only: [:show, :update]
  resources :tables, only: [] do
    post :deal_cards, on: :member
  end
end
