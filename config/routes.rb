# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  root to: "home#index"
  resources :hands, only: [:show, :update]
  resources :tables, only: [:new, :create, :edit, :update] do
    post :deal_cards, on: :member
    post :deal_first_hand, on: :member
  end
end
