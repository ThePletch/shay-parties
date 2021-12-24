Rails.application.routes.draw do
  scope "(:locale)" do
    devise_for :users, defaults: { locale: I18n.locale }
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

    # only for testing
    resources :addresses, only: [:create]


    # user-scoped events index
    resources :user, shallow: true, only: [] do
      resources :addresses, only: [:create]
      resources :events, only: [:index]
    end

    resources :mailing_lists do
      member do
        put 'sync_users'
      end
    end

    root "home#index"
  end
end
