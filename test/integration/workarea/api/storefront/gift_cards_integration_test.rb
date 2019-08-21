require 'test_helper'

module Workarea
  if Plugin.installed?(:api)
    module Api
      module Storefront
        class GiftCardsIntegrationTest < Workarea::IntegrationTest
          def test_balance_lookup
            gift_card = create_gift_card(
              to: 'bcrouse@weblinc.com',
              amount: 5.to_m
            )

            get storefront_api.gift_cards_balance_path,
                params: { email: 'foo@weblinc.com', token: gift_card.token }

            refute(response.ok?)
            assert_equal(404, response.status)

            get storefront_api.gift_cards_balance_path,
                params: { email: 'bcrouse@weblinc.com', token: 'foo' }

            refute(response.ok?)
            assert_equal(404, response.status)

            get storefront_api.gift_cards_balance_path,
                params: { email: 'bcrouse@weblinc.com', token: gift_card.token }

            assert(response.ok?)
            results = JSON.parse(response.body)

            assert_equal(gift_card.to, results['to'])
            assert_equal(gift_card.token, results['token'])
            assert_equal(gift_card.balance.cents, results['balance']['cents'])
          end
        end
      end
    end
  end
end
