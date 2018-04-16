Rails.application.routes.draw do
  devise_for :users
  mount Commontator::Engine => '/comments_api'

  resources :events do
    member do
      put 'rsvp'
    end

    resources :attendances, only: [:create, :update, :destroy]
  end

  root "events#index"
end
