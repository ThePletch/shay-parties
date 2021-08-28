Rails.application.routes.draw do
  devise_for :users
  mount Commontator::Engine => '/comments_api'

  resources :events, shallow: true do
    member do
      get 'ical'
    end

    resources :attendances, only: [:create, :update, :destroy]
    resources :polls, except: [:index, :show], shallow: true do
      resources :poll_responses, only: [:create, :update, :destroy]
    end
  end

  # user-scoped events index
  resources :user, shallow: true, only: [] do
    resources :events, only: [:index]
  end

  resources :mailing_lists do
    member do
      put 'sync_users'
    end
  end

  root "events#index"
end
