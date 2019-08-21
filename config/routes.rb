Workarea::Admin::Engine.routes.draw do
  scope '(:locale)', constraints: Workarea::I18n.routes_constraint do
    resources :payment_gift_cards do
      get :redemptions
    end
  end
end

Workarea::Storefront::Engine.routes.draw do
  scope '(:locale)', constraints: Workarea::I18n.routes_constraint do
    get 'gift_cards/balance', to: 'gift_cards#index'
    get 'gift_cards/lookup', to: 'gift_cards#lookup'

    namespace :checkout do
      patch 'gift_cards', to: 'gift_cards#add'
      delete 'gift_cards', to: 'gift_cards#remove'
    end
  end
end

if Workarea::Plugin.installed?(:api)
  Workarea::Api::Admin::Engine.routes.draw do
    resources :gift_cards do
      collection { patch 'bulk' }
    end
  end

  Workarea::Api::Storefront::Engine.routes.draw do
    resources :checkouts, only: [] do
      member do
        patch 'add_gift_card'
        delete 'remove_gift_card'
      end
    end

    get 'gift_cards/balance', to: 'gift_cards#balance'
  end
end
