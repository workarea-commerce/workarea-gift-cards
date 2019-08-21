require 'test_helper'

module Workarea
  if Plugin.installed?(:api)
    module Api
      module Storefront
        class CheckoutGiftCardsIntegrationTest < Workarea::IntegrationTest
          setup :setup_checkout

          def setup_checkout
            create_tax_category(
              name: 'Sales Tax',
              code: '001',
              rates: [{ percentage: 0.07, country: 'US', region: 'PA' }]
            )
            create_shipping_service(
              name: 'Ground',
              tax_code: '001',
              rates: [{ price: 7.to_m }]
            )

            product = create_product(
              name: 'Integration Product',
              variants: [{ sku: 'SKU1', regular: 5.to_m, tax_code: '001' }]
            )

            post storefront_api.carts_path
            @order_id = JSON.parse(response.body)['id']

            post storefront_api.cart_items_path(@order_id),
                 params: {
                   product_id: product.id,
                   sku: product.skus.first,
                   quantity: 2
                 }

            patch storefront_api.checkout_path(@order_id),
                  params: {
                    email: 'bcrouse@workarea.com',
                    billing_address: factory_defaults(:billing_address),
                    shipping_address: factory_defaults(:shipping_address)
                  }
          end

          def test_paying_with_gift_card
            card_one = create_gift_card(token: '123', amount: 10.to_m)
            card_two = create_gift_card(token: '456', amount: 20.to_m)

            patch storefront_api.add_gift_card_checkout_path(@order_id),
                  params: { gift_card_number: card_one.token }

            order = Order.find(@order_id)
            payment = Payment.find(order.id)

            assert_equal(1, payment.gift_cards.count)

            gift_card = payment.gift_cards.first
            assert_equal(card_one.token, gift_card.number)
            assert_equal(10.to_m, gift_card.amount)

            patch storefront_api.add_gift_card_checkout_path(@order_id),
                  params: { gift_card_number: card_two.token }

            payment.reload

            assert_equal(2, payment.gift_cards.count)

            gift_card = payment.gift_cards.last
            assert_equal(card_two.token, gift_card.number)
            assert_equal(8.19.to_m, gift_card.amount)

            delete storefront_api.remove_gift_card_checkout_path(@order_id),
                   params: { gift_card_id: payment.gift_cards.first.id }

            payment.reload

            assert_equal(1, payment.gift_cards.count)

            gift_card = payment.gift_cards.first
            assert_equal(card_two.token, gift_card.number)
            assert_equal(18.19.to_m, gift_card.amount)

            post storefront_api.complete_checkout_path(@order_id)
            assert(order.reload.placed?)
          end

          def test_reduces_balance_on_gift_card
            pass && (return) unless Workarea::GiftCards.uses_system_cards?

            gift_card = create_gift_card(amount: 5.to_m)

            patch storefront_api.add_gift_card_checkout_path(@order_id),
                  params: { gift_card_number: gift_card.token }

            post storefront_api.complete_checkout_path(@order_id),
                 params: {
                   payment: 'new_card',
                   credit_card: {
                     number: '1',
                     month: '1',
                     year: Time.now.year + 1,
                     cvv: '999'
                   }
                 }

            gift_card.reload
            assert_equal(0.to_m, gift_card.balance)
            assert_equal(5.to_m, gift_card.amount)
            assert_equal(5.to_m, gift_card.used)

            order = Order.find(@order_id)
            redemption = gift_card.redemptions.first
            assert_equal(order.placed_at, redemption.redeemed_at)
            assert_equal(5.to_m, redemption.amount)
          end
        end
      end
    end
  end
end
