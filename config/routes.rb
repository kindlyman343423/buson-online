Rails.application.routes.draw do
  # admin
  namespace :admin do
    # resources :videos, only:[:index, :show, :create, :update]
    resources :videos, only:[:index]

    resources :accounts, only:[:index] do
      member do
        patch :cancel_subscription
      end
    end

    resources :admin_staffs, only:[:index] do
      member do
        patch :cancel
      end
    end

    resources :admin_invitations, only:[:create]

    resources :articles, only:[:index, :show, :create, :update, :destroy] do
      member do
        patch :update_status
      end
    end

    resources :stripe_prices, only:[:create] do
      collection do
        get :get_latest_price
      end
    end
  end

  # account
  resource :account, only: [:create, :show, :update, :destroy] do
    member do
      get :confirm
      post :register_as_admin
    end
  end

  resources :articles, only: [:index, :create, :show, :update, :destroy]
end
