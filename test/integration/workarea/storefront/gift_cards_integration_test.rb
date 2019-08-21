require 'test_helper'

module Workarea
  module Storefront
    class GiftCardsIntegrationTest < Workarea::IntegrationTest
      def test_balance_lookup
        gift_card = create_gift_card(to: 'test@workarea.com', amount: 12.to_m)

        get storefront.gift_cards_lookup_path,
            params: {
              email: gift_card.to,
              token: gift_card.token
            }

        assert_redirected_to(storefront.gift_cards_balance_path)
        assert_equal(
          t(
            'workarea.storefront.flash_messages.gift_card_balance',
            balance: gift_card.balance.format
          ),
          flash[:success]
        )

        get storefront.gift_cards_lookup_path,
            params: {
              email: 'foo@workarea.com',
              token: gift_card.token
            }

        assert_equal(
          t('workarea.storefront.flash_messages.gift_card_not_found'),
          flash[:error]
        )

        get storefront.gift_cards_lookup_path,
            params: {
              email: gift_card.to,
              token: '125'
            }

        assert_equal(
          t('workarea.storefront.flash_messages.gift_card_not_found'),
          flash[:error]
        )
      end
    end
  end
end
