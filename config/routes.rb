Rails.application.routes.draw do
  devise_for :users
  mount Commontator::Engine => '/comments_api'

  resources :events, shallow: true do
    member do
      put 'rsvp'
    end

    resources :attendances, only: [:create, :update, :destroy]
    resources :polls, except: [:index, :show], shallow: true do
      resources :poll_responses, only: [:create, :update, :destroy]
    end
  end

  root "events#index"
end
