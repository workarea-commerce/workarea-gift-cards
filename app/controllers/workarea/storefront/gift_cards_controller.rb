module Workarea
  module Storefront
    class GiftCardsController < ApplicationController
      def index
      end

      def lookup
        gift_card = Workarea::GiftCards.gateway.lookup(params)

        if gift_card.present?
          flash[:success] = t(
            'workarea.storefront.flash_messages.gift_card_balance',
            balance: gift_card.balance.format
          )
        else
          flash[:error] = t('workarea.storefront.flash_messages.gift_card_not_found')
        end

        redirect_to gift_cards_balance_path
      end
    end
  end
end
