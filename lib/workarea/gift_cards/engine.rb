module Workarea
  module GiftCards
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::GiftCards

      config.to_prepare do
        [
          Storefront::OrderViewModel,
          Storefront::Checkout::SummaryViewModel,
          Storefront::Checkout::PaymentViewModel,
          Storefront::CartViewModel
        ].each do |klass|
          klass.send(:include, Workarea::Storefront::GiftCardOrderPricing)
        end
      end
    end
  end
end
