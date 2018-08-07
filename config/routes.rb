Rails.application.routes.draw do
  devise_for :users
  mount Commontator::Engine => '/comments_api'

  resources :events, shallow: true do
    member do
      put 'rsvp'
    end

    resources :attendances, only: [:create, :update]
    resources :polls, except: [:index, :show], shallow: true do
      resources :poll_responses, only: [:create, :update]
    end
  end

  resources :mailing_lists do
    member do
      put 'sync_users'
    end
  end

  root "events#index"
end
