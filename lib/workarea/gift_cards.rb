require 'workarea'
require 'workarea/storefront'
require 'workarea/admin'

module Workarea
  module GiftCards
    def self.gateway
      Workarea.config.gateways.gift_card.constantize.new
    end

    def self.uses_system_cards?
      Workarea::GiftCards.gateway.respond_to?(:uses_system_cards?) &&
        Workarea::GiftCards.gateway.uses_system_cards?
    end
  end
end

require 'workarea/gift_cards/version'
require 'workarea/gift_cards/engine'
require 'workarea/gift_cards/gateway'
