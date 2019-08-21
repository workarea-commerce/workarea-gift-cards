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
    patch 'checkout/add_gift_card', to: 'checkouts#add_gift_card'
  end
end

if Workarea::Plugin.installed?(:api)
  Workarea::Api::Admin::Engine.routes.draw do
    resources :payment_gift_cards
  end

  Workarea::Api::Storefront::Engine.routes.draw do
    resources :checkouts, only: [] do
      member do
        patch 'add_gift_card'
      end
    end

    get 'gift_cards/balance', to: 'gift_cards#balance'
  end
end
